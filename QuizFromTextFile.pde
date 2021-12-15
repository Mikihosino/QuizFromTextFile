//星野光希　21T075
import java.util.*;
import g4p_controls.*;
BufferedReader reader;
GLabel centerLabel;
GLabel questionLabel;
GLabel errorTitleLabel;
GLabel errorExplanationLabel;
GButton button1;
GButton button2;
GButton button3;
GButton button4;
String messageForFinalMessage;
String correctAnswerForErrorPage;
QuestionList questionList;

enum ProgramState {
  START,
  QUESTIONS,
  CORRECT,
  INCORRECT,
  FINAL
}

ProgramState currentState = ProgramState.START;

void setup() {
  createQuestions();
  size(400, 500);
  surface.setTitle("クイズ");
  G4P.setDisplayFont("MS Gothic", G4P.PLAIN, 24);
  errorTitleLabel = new GLabel(this, 20, 50, 360, 100);
  errorExplanationLabel = new GLabel(this, 20, 200, 360, 100);
  centerLabel = new GLabel(this, 20, 20, 360, 460);
  centerLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  questionLabel = new GLabel(this, 20, 10, 360, 100);
  questionLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  button1 = new GButton(this, 20, 100, 360, 70);
  button2 = new GButton(this, 20, 170, 360, 70);
  button3 = new GButton(this, 20, 240, 360, 70);
  button4 = new GButton(this, 20, 310, 360, 70);
}


void showQuestionsPage() {
    questionLabel.setVisible(true);
    button1.setVisible(true);
    button2.setVisible(true);
    button3.setVisible(true);
    button4.setVisible(true);
    displayQuestions();
}

void hideQuestionsPage() {
    questionLabel.setVisible(false);
    button1.setVisible(false);
    button2.setVisible(false);
    button3.setVisible(false);
    button4.setVisible(false);
}

void drawQuestionPage(){
  hideErrorPage();
  hideStartPage();
  showQuestionsPage();
}

void showStartPage() {
  centerLabel.setVisible(true);
  centerLabel.setText("QUESTION!");
}

void hideStartPage() {
  centerLabel.setVisible(false);  
}

void drawStartPage(){
  hideQuestionsPage();
  showStartPage();
  if (mousePressed == true) {
    currentState = ProgramState.QUESTIONS;
    draw();
  }
}

void drawCorrectPage(){
  showStartPage();
  centerLabel.setText("Correct!");
  hideQuestionsPage();
  if (mousePressed == true) {
    if (questionList.hasFinishedAllQuestions()==true) {
        messageForFinalMessage = "Answered " + questionList.getNumberOfCorrectAnswers() + " questions";
        currentState = ProgramState.FINAL;
    } else {
        currentState = ProgramState.QUESTIONS;
    }
    draw();
  }
}

void hideErrorPage() {
  errorTitleLabel.setVisible(false);
  errorExplanationLabel.setVisible(false);
}

void showErrorPage() {
  errorTitleLabel.setText("Incorrect!");
  errorExplanationLabel.setText("The correct answer is: " + correctAnswerForErrorPage);                   
  errorTitleLabel.setVisible(true);
  errorExplanationLabel.setVisible(true);
}

void drawIncorrectPage(){
  showErrorPage();
  hideQuestionsPage();
  if (mousePressed == true) {
    if (questionList.hasFinishedAllQuestions()==true) {
        messageForFinalMessage = ("You answered " + questionList.getNumberOfCorrectAnswers() + 
                                  " question(s) correctly!");
        currentState = ProgramState.FINAL;
    } else {
        currentState = ProgramState.QUESTIONS;    
    }
    draw();
  }
}

void drawFinalPage(){
  hideErrorPage();
  hideQuestionsPage();
  showStartPage();
  centerLabel.setText(messageForFinalMessage);
}

void draw() {
  background(220);
  switch (currentState) {
    case START: { drawStartPage(); break; }
    case QUESTIONS: { drawQuestionPage(); break; }
    case CORRECT: { drawCorrectPage(); break; }
    case INCORRECT: { drawIncorrectPage(); break; }
    case FINAL: { drawFinalPage(); break; }
  }
}

void displayQuestions() {
  Question question = questionList.getCurrentQuestion();
  if (question != null) {
    questionLabel.setText(question.getQuestion());
    List<String> choices = question.getChoices();
    button1.setText(choices.get(0));
    button2.setText(choices.get(1));
    button3.setText(choices.get(2));
    button4.setText(choices.get(3));  
  }
}

void handleButtonEvents(GButton button, GEvent event) {
  int count = questionList.getCurrentQuestionIndex();
  int numberOfCorrectAnswers = questionList.getNumberOfCorrectAnswers();
  if (event != GEvent.CLICKED) return;
  String selectedAnswer = button.getText();
  Question currentQuestion = questionList.getCurrentQuestion();
  String correctAnswer = currentQuestion.getCorrectAnswer();  
  if(correctAnswer.equals(selectedAnswer)){
    currentState = ProgramState.CORRECT;
    draw();
  }else{
    currentState = ProgramState.INCORRECT;
    correctAnswerForErrorPage = correctAnswer;
    draw();      
  }
  questionList.answer(selectedAnswer);
}

void createQuestions() {
  List<Question> list = new ArrayList<Question>();                       
  reader = createReader("/Users/mikihoshino/Downloads/question.txt"); 
  String line = null;
  do {
    try {
      line = reader.readLine();
      if (line !=null) {
        println(line);
        List<String> choiceList = new ArrayList<String>();
        String[] elements = line.split(",");
        for (int i=2; i<elements.length; i++) {
          choiceList.add(elements[i]);
        }
        String questionText = elements[0];
        int correctIndex = Integer.parseInt(elements[1]) + 1;
        String correctAnswer = elements[correctIndex];
        Question question = new Question(elements[0], choiceList, correctAnswer);
        list.add(question);
      }
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
  }while (line != null);
  questionList = new QuestionList(list);
}

class QuestionList {
  private List<Question> questions;
  private int currentQuestionIndex;
  private int numberOfCorrectAnswers;

  public QuestionList(List<Question> questionList) {
    questions = questionList;
    reset();
  }

  public void reset() {
    currentQuestionIndex = 0;
    numberOfCorrectAnswers = 0;
    Collections.shuffle(questions);
  }

  public void answer(String answer) {
    if (!hasFinishedAllQuestions() && questions.get(currentQuestionIndex).isCorrect(answer)) {
      numberOfCorrectAnswers++;
    }
    currentQuestionIndex++;
  }

  public Question getCurrentQuestion() {
    if (currentQuestionIndex < questions.size()) { 
      return questions.get(currentQuestionIndex);
    }
    return null;
  }

  public boolean hasFinishedAllQuestions() {
    return currentQuestionIndex >= questions.size();
  }

  public int getNumberOfCorrectAnswers() {
    return numberOfCorrectAnswers;
  }

  public int getCurrentQuestionIndex() {
    return currentQuestionIndex;
  }
}

class Question {
  private String question;
  private String correctAnswer;
  private List<String> choices;

  public Question(String question, List<String> choices, String correctChoice) {
    this.question = question;
    this.correctAnswer = correctChoice;
    this.choices = choices;
    Collections.shuffle(this.choices);
  }
  
  public String getCorrectAnswer(){
    return correctAnswer;
  }

  public String getQuestion() {    
    return question;
  }

  public List<String> getChoices() {
    return choices;
  }

  public boolean isCorrect(String answer) {
    return correctAnswer.equals(answer);
  }
  
  
}
