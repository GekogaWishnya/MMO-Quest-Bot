import regex
import time
from random import uniform
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import (ElementClickInterceptedException, TimeoutException, NoSuchElementException,
                                        StaleElementReferenceException)
from statemachine import StateMachine, State, Event
from statemachine.transition_list import TransitionList
from statemachine.exceptions import TransitionNotAllowed


LOGIN = "Player_1369417"
PASSWORD = "688025"
MOB = "Чумовой гриб".lower()
REGEX = r"\p{L}+"
TIMEOUT = 30


def is_error_page() -> bool:
    return "https://mmoquest.com/disconnect.php" in driver.current_url


def is_login() -> bool:
    try:
        driver.find_element(By.CLASS_NAME, "login")
        return True
    except NoSuchElementException:
        return False


def is_msg_window() -> bool:
    try:
        driver.find_element(By.XPATH, "//div[@class='btny button_alt_01']")
        return True
    except NoSuchElementException:
        return False


def is_daily_msg_window() -> bool:
    try:
        driver.find_element(
            By.XPATH,
            "//div[@class='msgQuests']/table/tbody/tr/td/div/table/tbody/tr/td/div[@class='button_alt_01']"
        )
        return True
    except NoSuchElementException:
        return False


def is_main_menu() -> bool:
    try:
        driver.find_element(By.CLASS_NAME, "perg_text")
        return True
    except NoSuchElementException:
        return False


def is_hunt_list() -> bool:
    try:
        driver.find_element(By.XPATH, "//img[@src='/mmoqimage/icond_1/powerHD.png']")
        return True
    except NoSuchElementException:
        return False


def is_fight_scene() -> bool:
    try:
        element = driver.find_element(By.XPATH, "//canvas[1]")
        return float(element.get_attribute("width")) > 0
    except NoSuchElementException:
        return False


def is_loot_table() -> bool:
    try:
        driver.find_element(By.CLASS_NAME, "win_prize")
        return True
    except NoSuchElementException:
        try:
            driver.find_element(By.CLASS_NAME, "win_prize_money")
            return True
        except NoSuchElementException:
            return False


def open_page():
    driver.get("https://mmoquest.com")


def reconnect():
    try:
        wait.until(EC.visibility_of_element_located((By.XPATH, "//div[@class='LButtonFlex']/button[1]"))).click()
    except TimeoutException:
        pass


def login():
    try:
        field = wait.until(EC.visibility_of_element_located((By.CLASS_NAME, "login")))
        field.clear()
        field.send_keys(LOGIN)
        driver.implicitly_wait(uniform(0.3, 0.7))
        field = driver.find_element(By.ID, "password-input")
        field.clear()
        field.send_keys(PASSWORD)
        driver.implicitly_wait(uniform(0.3, 0.7))
        driver.find_element(By.CLASS_NAME, "button_auth").click()
    except TimeoutException:
        pass


def close_msg():
    try:
        wait.until(EC.visibility_of_element_located((By.XPATH, "//div[@class='btny button_alt_01']"))).click()
    except (TimeoutException, ElementClickInterceptedException):
        pass


def close_daily_msg():
    try:
        wait.until(EC.element_to_be_clickable((
            By.XPATH,
            "//div[@class='msgQuests']/table/tbody/tr/td/div/table/tbody/tr/td/div[@class='button_alt_01']"
        ))).click()
    except TimeoutException:
        pass


def go_hunt_from_main_menu():
    try:
        wait.until(EC.visibility_of_element_located((By.CLASS_NAME, "perg_text")))
        driver.execute_script("showContent('/hunt/');")
    except TimeoutException:
        pass


def choose_mob():
    try:
        wait.until(EC.visibility_of_element_located((By.XPATH, "//img[@src='/mmoqimage/icond_1/powerHD.png']")))
        mobs = driver.find_elements(By.CLASS_NAME, "attackButtons")
        for i in range(len(mobs)):
            mob_name = ' '.join(regex.findall(REGEX, mobs[i].text)).lower()
            if mob_name == MOB:
                mobs[i + 1].click()

    except (TimeoutException, ElementClickInterceptedException):
        pass


def enable_auto():
    try:
        wait.until(EC.visibility_of_element_located((By.XPATH, "//canvas[1]")))
        driver.execute_script("mmobtl.setAuto(1);")
    except TimeoutException:
        pass


def exit_loot():
    try:
        wait.until(EC.visibility_of_element_located((By.CLASS_NAME, "win_prize")))
        driver.execute_script("showContent('/main.php', true);")
    except TimeoutException:
        pass


class MMOBOT(StateMachine, strict_states=True):
    initial = State("Initial", value=0, initial=True, enter=open_page)
    error_page = State("Error", value=1, enter=reconnect)
    login_page = State("Login", value=2, enter=login)
    msg_window = State("Message Window", value=3, enter=close_msg)
    daily_msg_window = State("Daily Message Window", value=4, enter=close_daily_msg)
    main_menu = State("Main menu", value=5, enter=go_hunt_from_main_menu)
    hunt_list = State("Hunt list", value=6, enter=choose_mob)
    fight_scene = State("Fight Scene", value=7, enter=enable_auto)
    loot_table = State("Loot Table", value=8, enter=exit_loot)

    transitions = TransitionList()
    transitions.add_transitions(error_page.from_(initial, login_page, msg_window, daily_msg_window, main_menu, hunt_list, fight_scene, loot_table, cond=is_error_page))
    transitions.add_transitions(login_page.from_(initial, error_page, msg_window, daily_msg_window, main_menu, hunt_list, fight_scene, loot_table, cond=is_login))
    transitions.add_transitions(msg_window.from_(error_page, daily_msg_window, main_menu, hunt_list, fight_scene, loot_table, cond=is_msg_window))
    transitions.add_transitions(daily_msg_window.from_(error_page, login_page, msg_window, main_menu, hunt_list, fight_scene, loot_table, cond=is_daily_msg_window))
    transitions.add_transitions(main_menu.from_(initial, error_page, login_page, msg_window, daily_msg_window, hunt_list, fight_scene, loot_table, cond=is_main_menu))
    transitions.add_transitions(hunt_list.from_(initial, error_page, login_page, msg_window, daily_msg_window, main_menu, cond=is_hunt_list))
    transitions.add_transitions(fight_scene.from_(initial, error_page, login_page, msg_window, daily_msg_window, hunt_list, cond=is_fight_scene))
    transitions.add_transitions(loot_table.from_(initial, error_page, login_page, msg_window, daily_msg_window, fight_scene, cond=is_loot_table))
    loop = Event(transitions, name="Loop")

    def on_enter_state(self, event: Event, state: State):
        print(f"Entering '{state.name}' state.")


if __name__ == "__main__":
    options = Options()
    # options.add_argument("--headless")
    options.set_preference("media.volume_scale", "0.0")

    # Явно указываем путь к geckodriver для обхода Selenium Manager (для ARCH архитектуры)
    service = Service(executable_path="/usr/local/bin/geckodriver")
    driver = webdriver.Firefox(service=service, options=options)

    wait = WebDriverWait(driver, 10, 1)

    bot = MMOBOT()
    last_state_change = time.time()
    while True:
        try:
            bot.loop()
            last_state_change = time.time()
        except TransitionNotAllowed:
            if time.time() - last_state_change > TIMEOUT:
                open_page()

            driver.implicitly_wait(uniform(1.0, 2.0))

        driver.implicitly_wait(uniform(0.5, 1.0))
