from time import sleep

def sleep_ms(delay: float) -> None:
    sleep(delay / 1000)

__all__ = ['sleep', 'sleep_ms']
