import asyncio
from kasa.iot import IotPlug

async def main():
    plug = IotPlug("192.168.5.132")
    await plug.connect(host="192.168.5.132")
    await plug.update()  # Fetch current state
    print(f"Initial state: {plug.is_on}")
    print("Turning off...")
    await plug.turn_off()
    await asyncio.sleep(3)  # Wait 3 seconds
    await plug.update()
    print(f"New state: {plug.is_on}")
    print("Turning back on...")
    await plug.turn_on()
    await plug.update()
    print(f"Final state: {plug.is_on}")

if __name__ == "__main__":
    asyncio.run(main())