# 0904
블루투스와 앱을 연동/ 블루투스를 통해 와이파이 정보, 식물 아이디를 받음
- 메가보드와 함께 연결하여 받은 정보들을 변수화하여 서버와의 통신 필요

# 0818
와이파이 연결된 상태 /w 모터
- 전력부족문제 해결 -> 모든 GND 통일 및 모터 전원 별도 인가 / 총 9V 2개(모터, 센서들)& 6V 1개(아두이노)
- 블루투스 tx 실패
- 조도 값에 대한 고민 -> 생각보다 cds가 예민하지 않음
- 와이파이 센서데이터 없으면 insert / 있으면 update 가능
- 와이파이로 가지고 온 데이터를 이용한 모터 조절 가능 #처음에 와이파이 initializing을 성공해야함!!! 
- 센서데이터 변수로 넘겨서 DB에 저장 예정

# 0817
와이파이 연결이 된 상태에서 제어
- 블루투스 데이터 전송이 안됨(softwareSerial?)
- 블루투스를 통한 앱에서의 데이터 전송 후 변수를 받아 그 값들로 제어 필요

# 0729
wifi webclient json parsing
- 서버에 접속하여 get방식을 통해 필요한 데이터를 아두이노로 가지고 옴/ 가지고 온 데이터 파싱을 통한 저장
- 서버에 suitablePlantData.php 작성 -> 적정 습도/ 조도 요청

# 0719
기존 코드에 http 통신 코드 삽입
- 주석 처리로 실제 와이파이 실험 해 봐야함 -> 공유기 포트포워딩 필요
- 서버에 arduino/input.php, process.php 추가 -> input.php는 후에 필요없고 테스트용, 아두이노에서 process.php로 get방식 사용하도록 넘김

# 0717
온습도 센서를 php를 통해 mysql에 저장하는 예시 코드
- 데이터를 삽입하는 것은 가능할 것 같으나 아두이노로 받는 데이터는 저장장치가 필요한 것으로 추정(micro sd)
- 3d 프린터를 활용한 화분에 아두이노 센서들의 삽입을 위한 선들의 길이 조정 필요 및 정확한 크기 파악 및 위치 확인 필요

# 0703
9V와 6V를 외부전원 아두이노에 각각 인풋/ 다이오드를 통해 5V 변압 후 와이파이 제외한 모든 모듈 연결
- 토양습토 프로브 작동확인(실험 완료)
- 온습도 센서 작동확인
- 모터 작동 확인
- 물수위센서 작동 확인
- 와이파이 모듈 작동확인
## 광센서를 통한 LED확인 필요 -> 광센서가 너무 커서 안 맞음
광센서 넣은 모델만 완성하면 하드웨어는 완료/ 와이파이를 통한 서버와의 변수 tx,rx 할 방법 조사

# 0625
- 모터 작동 확인
- 프로트 확인
- led 확인
- 물수위센서 임시 코드작성
- 조도센서 임시 코드 작성
## 조도센서, 물수위센서 구성 전
서버에서 데이터를 가져와서 하드코딩된 변수에 대입필요


