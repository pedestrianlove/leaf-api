# NTHU Trip Planner

[![Test API Calls](https://github.com/SOA-04/leaf-api/actions/workflows/test.yaml/badge.svg)](https://github.com/SOA-04/leaf-api/actions/workflows/test.yaml)

## Project Overview

The **NTHU Trip Planner** is a system that combines **Google Maps** with the **NTHU internal school bus schedule** to provide efficient trip planning for users within the university campus.
Users can input an department or coordinates of their desired **Destination**, and the system will generate a suggested **Trip** strategy.
The planned trip can consist of up to three different plans, depending on the availability of school buses:

1. **From Origin Location to **Bus Stop**:
 Guides the user from their current **Location** to the nearest school bus stop.

2. **Bus Ride to a Bus Stop Near the Destination**:
 The system plans the bus route to a stop that is closest to the user's **Destination**.

3. **Final Trip from Bus Stop to Destination**:
 Guides the user from the bus stop to the final **Destination**, which may involve walking, biking, or another mode of travel.

### Key Terminology

- **Location**: A specific point representing either the user's current position or the destination.
- **Trip**: A planned journey that includes various segments.
- **Origin**: The starting point of the trip.
- **Destination**: The final location the user wants to reach.
- **Duration**: The total time (in seconds) for the trip or each segment.
- **Distance**: The length (in meters) between two points in the trip.
- **Strategy**: The travel mode used for each segment, which could be one of the following:
  - **Bicycling**
  - **Walking**
  - **Driving**
  - **Transit**
  - **School Bus**
  
## How It Works

1. User inputs the **Destination** (either an department or coordinates).

2. The system calculates the best route, considering the user's **Origin**, available school bus routes, and the chosen **Strategy**.

3. The result is a trip plan, which can include up to three segments, depending on the bus schedule:
   - Walking or other **Strategy** to the bus stop.
   - Riding the school bus to a stop near the **Destination**.
   - Walking or other **Strategy** from the bus stop to the **Destination**.
   
4. The system provides details for each segment, including **Duration** and **Distance**.

This system simplifies navigation within the university and optimizes the use of school buses for more convenient travel.
