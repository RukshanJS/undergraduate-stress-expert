# Undergraduate Stress Expert

This is an expert system that helps an undergraduate student find a solution to his/her stress and related mental issues that occur due to academics or any other reason.

This expert system is developed for the university undergraduate course module _Logic Programming & Artificial Cognitive Systems_ at University of Moratuwa, Sri Lanka.

## Features

- Question-driven using forward chaining
- User-friendly graphical user interface (GUI)
- Explanations for conclusions
- Multiple alternate solutions
- Expandable rule base
- Handle uncertainty
- Conflict resolution

## Prerequisites

To run this program locally, you need to have the following installed and setup on your local computer. This program does not require an internet connection to run.

- Oracle Java version `18.0.2.1` (preferred)
- JESS version `71p2`
- Add `jess.jar` to the `CLASSPATH` environment variable (adding to `PATH` variable won't work)

## Run Locally

Clone the project

```bash
  git clone https://github.com/RukshanJS/undergraduate-stress-expert
```

Go to the project directory

```bash
  cd undergraduate-stress-expert
```

To run the program locally, execute

- On MacOS,

  ```bash
  ./app.command
  ```

- Using JESS CLI (any OS),

  ```bash
  java jess.Main USEexpert.clp
  ```

## Authors

- [@RukshanJS](https://www.github.com/RukshanJS)

## Acknowledgements

- [JESS in Action](https://www.manning.com/books/jess-in-action?origin=product-look-inside)
- [JESS reference](http://alvarestech.com/temp/fuzzyjess/Jess60/Jess70b7/docs/index.html)

## License

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

## Disclaimer

This app ("Undergraduate Stress Expert") provides only information, is not medical or treatment advice and may not be treated as such by the user. As such, this App may not be relied upon for the purposes of medical diagnosis or as a recommendation for medical care or treatment.

The information on this App is not a substitute for professional medical advice, diagnosis or treatment. All content, including text, graphics, images and information, contained on or available through this App is for general information and educational purposes only
