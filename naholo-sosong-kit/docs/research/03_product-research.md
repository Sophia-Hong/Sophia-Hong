# 소액사건 나홀로소송 AI 에이전트 키트 — 프로덕트 리서치 보고서

- 작성일: 2026-09-21
- 범위: 소가 3,000만원 이하 민사 소액사건(가소)의 나홀로소송자를 보조하는 AI 에이전트 키트 설계용 공개 자료 수집·구조화
- 관점: 이 키트는 대한법률구조공단·법원 안내 서비스를 **대체가 아니라 보완**한다(무료 구조 대상자는 공단으로 라우팅).

---

## 0. 수집 방법과 접근 실패 기록 (반드시 읽을 것)

이번 세션의 네트워크 환경(에이전트 프록시)은 한국 정부·법원·법률 도메인 대부분에 대해 CONNECT 403(EGRESS_BLOCKED)을 반환했다. 따라서 아래 자료는 **WebSearch 결과 스니펫(검색엔진 색인 요약)** 을 근거로 구조화했고, 원문 페이지를 직접 열어 확인한 것은 github.com 2건뿐이다. 각 항목의 숫자·조문은 **한국 네트워크에서 원문 재검증**이 필요하다(재검증 체크리스트는 §10).

| 도메인 | 접근 결과 | 비고 |
|---|---|---|
| https://pro-se.scourt.go.kr | 실패 (DNS ENOTFOUND + 프록시 403) | 검색 색인에는 구 URL(`/wsh/wsh000/WSHMain.jsp`, `/wsh/wsh500/WSH520.jsp` 소장, `/wsh/wsh100/WSH170_1.jsp` 일반소송 이외 절차)이 남아 있으나, 콘텐츠는 전자소송포털 "나홀로소송 도움말"로 이관된 것으로 보임 |
| https://ecfs.scourt.go.kr | 실패 (EGRESS_BLOCKED) | 메뉴 URL은 검색 색인에서 복원 |
| https://www.klac.or.kr / https://support.klac.or.kr | 실패 (EGRESS_BLOCKED) | 〃 |
| https://www.law.go.kr / https://open.law.go.kr | 실패 (EGRESS_BLOCKED) | API 파라미터는 2차 자료(GitHub README)와 기존 지식으로 보완, 검증 필요 표시 |
| https://glaw.scourt.go.kr, https://portal.scourt.go.kr, https://openapi.scourt.go.kr | 실패 (EGRESS_BLOCKED) | |
| https://casenote.kr, https://lbox.kr | 실패 (EGRESS_BLOCKED) | |
| https://www.easylaw.go.kr (찾기쉬운 생활법령정보) | 실패 (EGRESS_BLOCKED) | 검색 스니펫 풍부 → 다수 인용 |
| https://www.data.go.kr, https://www.aihub.or.kr, https://huggingface.co | 실패 (EGRESS_BLOCKED) | |
| 언론(lawtimes.co.kr, news.nate.com, fnnews.com, mt.co.kr, hankyung.com, munhwa.com) | 실패 (EGRESS_BLOCKED) | 검색 스니펫만 사용 |
| https://github.com (jurisupport 가이드, taendong/law-search) | **성공** | Open API 발급 절차·파라미터 확인 |
| ko.wikibooks.org, namu.wiki, vyomakesa.com, macromaster.dev | 실패 (EGRESS_BLOCKED) | |

---

## 1. 대법원 나홀로소송 (pro-se.scourt.go.kr → 전자소송포털 "나홀로소송 도움말")

### 1.1 현황
- 구 사이트 `pro-se.scourt.go.kr`는 DNS 조회 자체가 실패했다. 검색 색인에는 `https://pro-se.scourt.go.kr/wsh/wsh000/WSHMain.jsp`(메인), `https://pro-se.scourt.go.kr/wsh/wsh500/WSH520.jsp`(소장), `https://pro-se.scourt.go.kr/wsh/wsh100/WSH170_1.jsp`(일반소송 이외 절차)가 남아 있다.
- 2025년 전자소송 시스템 개편 이후 동일 콘텐츠가 **전자소송포털(ecfs.scourt.go.kr/psp/…) 내 "나홀로소송 도움말"·"사건유형별 절차안내"** 로 통합되었다. 키트는 구 URL 대신 아래 신 URL을 기준으로 삼아야 한다.

### 1.2 복원한 메뉴 구조 (전자소송포털 기준, 검색 색인으로 확인된 URL)

| 메뉴 | 하위 항목 | URL |
|---|---|---|
| 전자소송포털 메인 | | https://ecfs.scourt.go.kr/psp/index.on?m=PSP004M01 |
| 나홀로소송 도움말 > 소장 작성방법 | 소장의 대표유형 안내 | https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M01 |
| 〃 | 소요되는 비용 | https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M03 |
| 나홀로소송 도움말 > 피고의 대응 | 지급명령에 대한 이의 | https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M06 |
| 사건유형별 절차안내 > 민사 > 민사소송의 진행 | 민사소송의 개요 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M01 |
| 〃 | 소의 제기 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M02 |
| 〃 | 기일의 준비 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M04 |
| 〃 | 기일의 진행 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M05 |
| 사건유형별 절차안내 > 민사 > 일반소송 외 절차 | 소액사건심판 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M10 |
| 〃 | 민사조정절차 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M11 |
| 〃 | 지급명령(독촉)절차 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M12 |
| 사건유형별 절차안내 > 강제집행 | 채권에 대한 강제집행 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP735M04 |
| 공통안내 | 전자소송이용안내 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M03 |
| 공통안내 | **양식모음**(HWP 서식 다운로드) | https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M24 (검색: `&searchword=소장&minGubun=a`) |
| 공통안내 | 인증서 안내 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M02 |
| 공통안내 | 법원상담사례 | https://ecfs.scourt.go.kr/psp/index.on?m=PSP721M01&s=PSP721M02 |
| 팝업 | 인지액 계산방법 | https://ecfs.scourt.go.kr/psp/link.on?m=PSP007P01 |
| 구 전자소송 안내(잔존) | 전자소송 이용안내 / 준비 / 소액 인지대 | https://ecfs.scourt.go.kr/ecf/ecf400/ECF430.jsp , …/ECF420.jsp , …/ECF460.jsp |
| 전자민원센터(대법원) | 소액사건재판 절차 | https://help.scourt.go.kr/nm/min_1/min_1_5/min_1_5_1/index.html |
| 〃 | 민사조정 신청안내 | https://help.scourt.go.kr/nm/min_1/min_1_6/min_1_6_2/index.html |
| 〃 | 양식모음 | https://www.scourt.go.kr/nm/minwon/doc/DocListAction.work |
| 법원 AI 챗봇(소송절차 안내) | | https://sjbot.scourt.go.kr/ |

### 1.3 절차 안내 요지 (검색 스니펫 기반)
- **소액사건심판**: 소가 3,000만원 이하 금전·대체물·유가증권 지급 청구의 제1심 민사사건. 소 제기 후 법원이 **이행권고결정**을 하면 변론기일을 바로 잡지 않고 피고에게 결정등본을 송달, 2주 내 이의가 없으면 확정판결과 같은 효력. 이의가 있으면 변론기일 지정(원칙 1회 변론 종결). (easylaw 소액사건재판 https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=239&ccfNo=1&cciNo=1&cnpClsNo=1)
- **지급명령(독촉절차)**: 금전 등 일정 수량 지급 청구, 채무자 심문 없이 서류심사로 발령, 송달일부터 2주 내 이의신청 시 그 범위에서 실효 → 소송으로 이행. 인지는 소송의 1/10, 송달료는 당사자 1인당 6회분. (ecfs PSP730M12; easylaw https://www.easylaw.go.kr/CSP/CnpClsMainBtr.laf?popMenu=ov&csmSeq=568&ccfNo=3&cciNo=3&cnpClsNo=2)
- **민사조정**: 신청 수수료는 소송 인지액의 1/10(1천원 미만→1천원, 100원 미만 절사), 송달료 당사자 1인당 5회분, 조정 성립 시 확정판결과 동일 효력, 조정에 갈음하는 결정은 2주 내 이의 가능. (easylaw https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=568&ccfNo=3&cciNo=1&cnpClsNo=2)
- **소송비용(인지·송달료)**: §4.4 참조. 전자소송 제출 시 인지 10% 감액.

### 1.4 제공 서식(양식모음)과 작성 예시
검색 색인에서 확인된 서식명(HWP): 소장(대여금·물품대금·임대차보증금·손해배상 등 유형별 작성례), 답변서, 준비서면, 증인신청서, 사실조회신청서, 문서제출명령신청서, 문서송부촉탁신청서, 지급명령신청서, 지급명령 이의신청서, 이행권고결정 이의신청서, 주소보정서, 공시송달신청서, 당사자표시정정신청서, 소취하서, 기일변경신청서, 채권압류 및 추심명령 신청서. 
- 양식모음: https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M24
- 소장 대표유형 안내(청구취지·청구원인 작성례): https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M01
- 소장 필요적 기재사항(민소법 §249): 당사자·법정대리인, 청구취지, 청구원인 + 입증방법·첨부서류. (easylaw 소장작성방법 https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=4&cciNo=1&cnpClsNo=1)
- ※ 서식 파일 자체는 이번 세션에서 다운로드 불가. 키트 구현 시 **양식모음 페이지에서 HWP를 내려받아 필드 스키마를 추출**하는 작업이 필요하다.

---

## 2. 대법원 전자소송 (ecfs.scourt.go.kr)

| 단계 | 내용 (스니펫 기반) | URL |
|---|---|---|
| 사용자등록 | 회원가입(개인/법인/대리인) 후 통합로그인. 공동인증서 또는 간편인증(민간인증서) 필요 | 로그인 https://ecfs.scourt.go.kr/psp/index.on?m=PSP101M01 ; 인증서 안내 https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M02 |
| 전자소송 동의 | 원고: [서류제출 > 민사본안 > 소장] 진입 시 해당 사건에 대해 전자소송 동의. 피고/진행 중 전환: [나의전자소송 > 전자소송사건등록]에서 동의 후 전자 진행 | 서류제출 https://ecfs.scourt.go.kr/psp/index.on?m=PSPA11M01 ; 민사본안 https://ecfs.scourt.go.kr/psp/index.on?m=PSPA13M01 ; 전체서류 https://ecfs.scourt.go.kr/psp/index.on?m=PSPA13M04 |
| 소장 제출 | 사건기본정보(법원·소가·사건명) → 당사자 입력(성명·주민번호/법인번호·주소·연락처) → 청구취지·청구원인 입력(직접 입력 또는 파일 첨부) → 입증서류(갑 제1호증…) 개별 등록 후 '입증서류 저장' → 첨부서류 → 소송비용 자동계산·납부(계좌이체/카드) → 전자서명 제출 | https://ecfs.scourt.go.kr/psp/index.on?m=PSPA13M01 ; 실무 후기 https://brunch.co.kr/@shala/79 ; 법무법인 도모 가이드 https://domolaw.co.kr/legal-guide/96d940cd-0ff0-4cfb-8ac9-3f4a79c6a934 |
| 전자송달 | 동의자는 포털에서 전자문서 송달·열람. 등록된 이메일/문자로 통지. **확인하지 않으면 통지 후 1주 경과 시 송달 간주**(민사소송 등에서의 전자문서 이용 등에 관한 법률 §11 — 재검증 필요) | 업무처리지침(재일 2012-1) 요약 https://korea.legal/대법원-예규/재판예규/민사소송-전자문서-이용-업무처리지침/ |
| 기일 확인 | 나의사건관리 > 진행중사건 / 완료된사건; 비회원은 '나의사건검색'(법원명+사건번호+당사자명 2자 이상) | https://ecfs.scourt.go.kr/psp/index.on?m=PSP221M01 ; https://ecfs.scourt.go.kr/psp/index.on?m=PSP22DM01 ; https://ssgo.scourt.go.kr/ ; https://www.scourt.go.kr/portal/information/events/search/search.jsp |
| 주소보정 | 송달불능 시 주소보정명령 → (피고 주민번호를 알면) 행안부 연계로 포털에서 최신주소 자동 보정, 아니면 보정명령서 지참하여 주민센터에서 초본 발급(500원/통) 후 주소보정서 제출 → 최후 수단으로 공시송달 신청 | easylaw 주소보정 https://www.easylaw.go.kr/CSP/OnhunqueansInfoRetrieve.laf?onhunqnaAstSeq=85&onhunqueSeq=1940 ; 대법원 FAQ https://www.scourt.go.kr/nm/minwon/faq/FaqViewAction.work?mode=B&functioncode=129&bulletinid=2064 |
| 통계 | 2024년 소액사건 전자소송 접수 506,956건, 접수 전체의 99.9% (2025 사법연감) | https://www.lawtimes.co.kr/news/211723 |

- 대법원은 2025년 1월 차세대 전자소송 시스템(챗봇·AI 추천 포함) 구축을 발표: https://www.hankookilbo.com/news/article/A2025013010540003649
- 나무위키 전자소송 개요(비공식): https://namu.wiki/w/전자소송

---

## 3. 대한법률구조공단 (klac.or.kr / support.klac.or.kr / helplaw24.go.kr)

### 3.1 사이트 구조
| 구분 | URL | 내용 |
|---|---|---|
| 공단 메인 | https://www.klac.or.kr/ | 대표전화 132, 사이버·화상 상담 |
| 법률정보 > 법률서식(전체) | https://www.klac.or.kr/legalinfo/legalFrm.do | 소장(대여금·물품대금·임대차보증금·손해배상 등), 답변서, 지급명령신청서, 이행권고결정 이의신청서 등. 회원가입 후 서식 작성·저장 |
| 법률정보 > 소송비용 등 자동계산 | https://www.klac.or.kr/legalstruct/autoCostCalculation.do | 본안사건 인지·송달료 계산기(키트의 계산 로직 검증용 레퍼런스) |
| 법률구조 대상자 안내(소득별) | https://klac.or.kr/legalstruct/legalRescueGuide.do?codeValue=INC003 | 기준 중위소득 125% 이하 |
| 사건유형별 구조대상자 | https://klac.or.kr/legalstruct/legalRescueGuideTargetType.do?codeId=&codeValue=CAS002 | |
| 법률지원단 서식 | https://www.klac.or.kr/pil/klac-format | |
| AI 챗봇 "법률똑똑이" | https://klac.or.kr/startingChat.do?channelCd=CHATBOT | 가족관계등록·주택/상가임대차·상속·개인회생·파산 등 Q&A, 상담예약, 나의사건검색 |
| **혼자하는 소송 법률지원센터(나홀로소송)** | https://support.klac.or.kr/ (검색 https://support.klac.or.kr/front/search/searchList.do) | 서식 편집기, 민사소송 개념·절차, 소송 준비, **유형별 요건사실** 페이지 |
| 〃 인지액 | https://support.klac.or.kr/front/contents/01/007.do , 산출방법 https://support.klac.or.kr/front/contents/lawsuit/004.do | |
| 〃 송달료 | https://support.klac.or.kr/front/contents/01/008.do | |
| 〃 주택임대차보증금 반환 > 요건사실 | https://support.klac.or.kr/front/contents/06/01003-01.do | 유형별 요건사실 페이지가 존재함을 확인(다른 유형 URL은 dirId/contentId 패턴: `/front/contents/contentsView.do?dirId=07&contentId=022`, `/front/contents/lawSuitContentsView.do?dirId=lawsuit&contentId=015`) |
| 공단 전자접수시스템 | https://support.klac.or.kr/eklac/main.do | |
| 공공데이터포털: 법률서식(파일) | https://www.data.go.kr/data/3045357/fileData.do | 2014 서식 묶음 |
| 공공데이터포털: **법률서식작성방법(2025-04-14)** | https://www.data.go.kr/data/15142986/fileData.do | 소장 당사자·사건명·청구취지·청구원인·입증방법·첨부서류 작성 요령 — 키트 프롬프트 근거로 활용 가치 높음 |
| 공공데이터포털: 혼자하는소송 뉴스정보(2025-11-11) | https://www.data.go.kr/data/15152032/fileData.do | |
| **법률구조 플랫폼(법무부, 2026-01-21 개시)** | https://www.helplaw24.go.kr/ | 35개 기관 통합, AI가 사례·법령·판례 학습 데이터로 적합 서비스 제안, 법률서식·상담사례 수록, AI 콜센터 1661-3119. 공단 서식 미러: https://www.helplaw24.go.kr/statuteinfo/template/korea/list |
| 생활법률 상담사례 | 공단 사이버상담 사례는 klac.or.kr 법률정보 메뉴 및 helplaw24 사례 DB에 수록(직접 확인 불가) | |

### 3.2 무료 법률구조 대상 (키트의 "공단 라우팅" 규칙)
- 소득 기준: 기준 중위소득 125% 이하 (2025년 1인 2,990,017원, 2인 4,915,823원, 3인 6,281,691원, 4인 … 스니펫 수치 상호모순 있어 재확인 필요). https://klac.or.kr/legalstruct/legalRescueGuide.do?codeValue=INC003
- 사건유형별 무료 대상: 임금·퇴직금 체불 근로자(최종 3개월 월평균임금 400만원 미만), 농어민, 기초생활수급자, 장애인, 국가유공자, 범죄피해자, 소액임차인 등. https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=1533&ccfNo=3&cciNo=3&cnpClsNo=2 ; 무료법률구조사업 시행지침 PDF https://www.easylaw.go.kr/CSP/FlDownload.laf?flSeq=1734314134366
- 설계 함의: 인테이크 단계에서 (가구원수, 월소득, 사건유형: 임금/임대차/범죄피해 여부)를 물어 **무료 구조 대상이면 공단 132·helplaw24로 먼저 안내**하고, 키트는 "공단 상담 준비 자료(크로놀로지·증거표)"를 만들어 주는 역할로 전환한다.

---

## 4. 법령: 소액사건심판법·규칙·민사소송법·인지법·송달료

원문 링크(모두 EGRESS_BLOCKED, 한국망에서 열람):
- 소액사건심판법 https://www.law.go.kr/법령/소액사건심판법 (lsId=001219; 개정이유 https://www.law.go.kr/LSW/lsRvsRsnListP.do?lsId=001219&chrClsCd=010102 ; 위키문헌 https://ko.wikisource.org/wiki/대한민국_소액사건심판법)
- 소액사건심판규칙 https://www.law.go.kr/LSW/lsInfoP.do?lsiSeq=52485 (제1조의2 https://www.law.go.kr/LSW//lsSideInfoP.do?lsiSeq=187995&joNo=0001&joBrNo=02&docCls=jo&urlMode=lsScJoRltInfoR)
- 민사소송법 https://law.go.kr/lsInfoP.do?lsiSeq=4791
- 민사소송 등 인지법 제2조 https://www.law.go.kr/LSW/LsiJoLinkP.do?docType=JO&lsNm=민사소송+등+인지법&joNo=000200000&languageType=KO&paras=1 (위키문헌 https://ko.wikisource.org/wiki/민사소송_등_인지법)
- CaseNote 조문 페이지(비공식, 해설 포함): 소액사건심판법 §2 https://casenote.kr/법령/소액사건심판법/제2조 , §3 …/제3조 , §5조의3 …/제5조의3 , §10 …/제10조 , §11조의2 …/제11조의2 ; 민사소송법 §8 https://casenote.kr/법령/민사소송법/제8조 , §148 …/제148조 , §256 …/제256조 , §257 …/제257조 ; 인지법 §2 https://casenote.kr/법령/민사소송_등_인지법/제2조

### 4.1 소액사건심판법 핵심 조문 (스니펫 + 조문 구조 지식, 재검증 필요)
| 조문 | 내용 | 키트 활용 |
|---|---|---|
| §2 적용범위 | 소액사건 범위는 대법원규칙으로 정함 | |
| 규칙 §1조의2 | **제소 시 소가 3,000만원 이하**의 금전·대체물·유가증권 일정 수량 지급 청구 제1심 민사사건(2016.11.29 대법원규칙 제2694호, 2017.1.1 시행; 종전 2,000만원). 소 변경으로 초과 시 제외 | 소가 계산 후 3,000만원 초과 시 "가단"으로 안내 |
| §3 상고·재항고 제한 | 법률·명령·규칙·처분의 헌법위반 / 대법원 판례 상반 판단만 상고이유 | "3심 기대 금지" 안내 |
| §4 구술 제소 | 구술로 소 제기 가능(법원사무관 등이 제소조서 작성) | |
| §5조의3~5조의8 | **이행권고결정**: 소장부본 첨부하여 청구취지대로 이행 권고 → 피고는 송달일부터 **2주 내 서면 이의** → 이의 없으면 확정판결과 동일 효력(§5조의7), 결정등본으로 강제집행(§5조의8) | 원고 타임라인·집행 안내 |
| §7 기일지정 | 판사는 바로 변론기일 지정 가능, **되도록 1회 변론으로 종결** | "첫 기일에 모든 증거 제출" 원칙 |
| §8 소송대리 특칙 | **배우자·직계혈족·형제자매는 법원 허가 없이 소송대리** 가능(신분·수권관계 서면 증명; 2023 개정으로 '호주' 삭제) | 가족 대리 옵션 안내 |
| §9 심리 특칙 | 소장·준비서면 등 기록상 청구가 이유 없음이 명백하면 **변론 없이 기각** 가능 | 소장 완성도의 중요성 |
| §10 증거조사 특칙 | 직권 증거조사, 증인은 판사가 신문, 서면증언(진술서)으로 갈음 가능 | 진술서 서식 활용 |
| §11조의2 판결 특례 | 변론종결 즉시 선고 가능, 판결서에 이유 생략 가능. **2023.3.28 개정(법률 제19281호)**: 기판력 범위가 달라지거나 일부 기각 시 산정근거, 쟁점 복잡 시 이유 기재 노력 의무(§11조의2③, 시행 후 제소분부터) | |
| 2026.3.17 개정 | 해사·국제상사법원 관련 정비(민사소송법 법률 제21455호 동시 개정), **2028.3.1 시행**. 소액사건 실체 절차 변경 없음 | 2025~2026 실질 개정은 없음으로 정리 |

근거: https://www.lawtimes.co.kr/news/106117 (3,000만원 상향), https://www.newsdaily.kr/news/articleView.html?idxno=224805 (2023 개정 통과), https://www.lawtimes.co.kr/news/articleView.html?idxno=222814 (2026 하반기 변화), https://www.lawtimes.co.kr/news/14123 (소액사건 법령해석 통일 직권판단), 헌재 2025헌바52 https://casenote.kr/헌법재판소/2025헌바52 (소액사건 관련 헌법소원 — 내용 미확인), 경실련 소액사건 실태 https://ccej.or.kr/posts/Kmt7pY

### 4.2 민사소송법 핵심 조문 (나홀로소송 관련)
| 조문 | 내용 |
|---|---|
| §2~§3 보통재판적 | 피고 주소지 법원 |
| **§8 특별재판적** | 재산권 소는 **의무이행지** 법원 가능. 대여금·물품대금·보증금·손해배상금 등 지참채무는 채권자(원고) 주소지가 의무이행지 → 원고 주소지 법원 제소 가능. https://ko.wikipedia.org/wiki/대한민국_민사소송법_제8조 ; easylaw 소액사건 관할 https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=239&ccfNo=2&cciNo=1&cnpClsNo=2 |
| §148 한쪽 불출석 | 진술 간주·자백 간주(피고) |
| §150 자백간주 | 다투지 않으면 자백으로 간주 |
| §194 공시송달 | 통상 조사로 송달 불가 시 최후 수단 |
| §249 소장 기재사항 | 당사자·법정대리인, 청구취지, 청구원인 |
| §254 소장심사·보정명령 | 기재사항 흠·인지 미납 시 보정명령, 불이행 시 **소장 각하** |
| §255 소장부본 송달 → §256 답변서 **30일** → §257 무변론판결 | 피고가 30일 내 답변서 미제출 시 자백 간주·무변론 판결(대법원 2020다255085: 답변서 간과한 무변론판결은 위법) https://jifi.scourt.go.kr/portal/news/NewsViewAction.work?seqnum=7436&gubun=4 |
| §268 양쪽 불출석 | 2회 불출석 후 1개월 내 기일지정신청 없으면 **소 취하 간주** |
| §462~§474 독촉절차 | 지급명령 요건·이의·소송 이행 https://www.law.go.kr/lsLinkProc.do?…joLnkStr=「민사소송법」+제462조+내지+제474조 |

### 4.3 관련 특별법
- 민사소송 등에서의 전자문서 이용 등에 관한 법률(전자송달 간주 규정) — 원문 미확인.
- 주택임대차보호법(보증금 반환·대항력), 근로기준법 §36(금품청산 14일)·§43, 민법 §163(3년 단기소멸시효: 물품대금·임금 등), §741(부당이득), §750(불법행위), §598(소비대차), §618(임대차).

### 4.4 인지액 계산식 (민사소송 등 인지법 §2, 스니펫으로 확인)
```
소가 < 1,000만원            : 소가 × 0.005
1,000만원 ≤ 소가 < 1억원    : 소가 × 0.0045 + 5,000원
1억원 ≤ 소가 < 10억원       : 소가 × 0.004  + 55,000원
10억원 ≤ 소가              : 소가 × 0.0035 + 555,000원
※ 산출액 1,000원 미만 → 1,000원 / 1,000원 이상은 100원 미만 절사
※ 전자소송 제출 시 위 금액의 90% (10% 감액, 인지법 §16 — 조 번호 재확인)
※ 지급명령·민사조정 신청: 위 인지액의 1/10
※ 항소 1.5배, 상고 2배 (소액사건은 상고 제한)
```
소액사건 예시: 소가 500만원 → 25,000원(종이) / 22,500원(전자). 소가 3,000만원 → 30,000,000×0.0045+5,000 = 140,000원(종이) / 126,000원(전자).
출처: https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=2&cciNo=4&cnpClsNo=3 ; https://korea.legal/wiki/인지액과-송달료/ ; https://www.nepla.ai/law/민사소송등인지법 (현행 2025.03.01) ; 계산기 비교용 https://www.dacalc.com/kr/lawsuit-cost/ , https://www.amazingtour.kr/business/litigation-cost-calculator.html

### 4.5 송달료 예납 기준 (송달료규칙의 시행에 따른 업무처리요령 별표 1)
- **1회 송달료 5,500원 (2025.6.1~ 인상)**: https://korea.legal/실무자료/법원-송달료-1회분-5500원-2025-06-01/ ; 대법원 공지 https://scourt.go.kr/portal/news/NewsViewAction.work?seqnum=2588&gubun=3
- 계산: 1회 송달료 × 당사자 수 × 사건별 회수
| 사건 | 회수(당사자 1인당) | 근거 |
|---|---|---|
| 민사 제1심 소액사건(가소) | **10회** | easylaw, 인천지법 안내 https://incheon.scourt.go.kr/dcboard/new/DcNewsViewAction.work?seqnum=194&gubun=47&pageIndex=1&cbub_code=000240 |
| 민사 제1심 단독·합의(가단·가합) | 15회 | 스니펫 미확인(기존 지식) |
| 지급명령(차·차전) | 6회 | easylaw 독촉절차 |
| 민사조정(머) | 5회 | easylaw 민사조정 |
| 항소(나) | 12회 | 기존 지식, 재확인 |
- 소액 예시: 원고1·피고1 → 2 × 10 × 5,500 = **110,000원**. 송달료는 인지와 달리 현금(가상계좌) 납부, 잔액은 종결 후 환급.
- 송달료 조견표(법무사 자료): http://lawss.kr/lawyer/lawbook/datum/item_each_view.php?no=3 ; 공단 송달료 페이지 https://support.klac.or.kr/front/contents/01/008.do

---

## 5. 판례 검색 소스와 "할루시네이션 검증 파이프라인" 실현 가능성

### 5.1 소스 비교
| 소스 | URL | 접근 방식 | 수록 범위 | 제약 |
|---|---|---|---|---|
| **국가법령정보 공동활용 Open API(법제처)** | https://open.law.go.kr/LSO/main.do ; 판례목록 가이드 https://open.law.go.kr/LSO/openApi/guideResult.do?htmlName=precListGuide ; 판례본문 가이드 https://open.law.go.kr/LSO/openApi/guideResult.do?htmlName=precInfoGuide ; 모바일 https://open.law.go.kr/LSO/openApi/guideResult.do?htmlName=mobPrecListGuide | REST(XML/JSON/HTML) | 대법원 판례 중심 + 선별 하급심(국세법령정보·근로복지공단 산재판례 등 출처별) | 회원가입 → "OPEN API 신청" → "API인증키관리"에서 OC(=가입 이메일 ID) 확인. 무료. 개발계정 **일 10,000건**(2차 자료), Referer 헤더 요구 사례. 하급심 대부분 미수록 |
| 공공데이터포털 미러 | https://www.data.go.kr/data/15059269/openapi.do (법제처_판례 목록 조회) ; https://www.data.go.kr/data/15000115/openapi.do | data.go.kr 인증키 | 동일 | 활용신청 승인 필요 |
| 법제처 생활법령 대법원판례 검색 OpenAPI(XML) | http://open.moleg.go.kr/search/oneclick/openAPIView07.html ; 공공데이터 안내 https://www.moleg.go.kr/menu.es?mid=a10203010000 | XML | 대법원 판례 | 갱신 1일 1회 |
| **사법정보공개포털(대법원)** | https://portal.scourt.go.kr/ ; 판례 https://portal.scourt.go.kr/pgp/index.on?m=PGP1011M01&l=N&c=900 ; 전체검색 https://portal.scourt.go.kr/pgp/index.on?c=900&l=N&m=PGP101M02 ; 판결서 인터넷열람 https://portal.scourt.go.kr/pgp/index.on?c=900&l=N&m=PGP004M01 ; **허위 사건번호 확인** https://portal.scourt.go.kr/pgp/index.on?m=PGP210M01&l=N&c=200 | 웹 UI(공식 API 없음) | 종합법률정보 통합, 판결서 열람(비실명, 유료 1,000원/건) | 자동화·크롤링 불가 전제. 허위 사건번호 확인 서비스는 2026.2.20 개시(보도자료 https://sc.scourt.go.kr/portal/news/NewsViewAction.work?pageIndex=1&searchWord=&searchOption=&seqnum=2935&gubun=6 ; https://v.daum.net/v/20260220170526596) |
| 종합법률정보(구) | https://glaw.scourt.go.kr/wsjo/intesrch/sjo022.do ; 판례 상세검색 https://glaw.scourt.go.kr/wsjo/panre/sjo060.do ; 디렉토리 https://glaw.scourt.go.kr/wsjo/panre/sjo080.do ; https://glaw.scourt.go.kr/wsjo/panre/sjo050.do?m=040403 | 웹 UI. 항목범위(판시사항/판결요지/전문), 사건종류, 선고일자, 법원명 필터 | 대법원·선별 하급심 | 사건번호 직접 검색 UI 있음(URL 파라미터 패턴은 미확인). 사법정보공개포털로 이관 중 |
| **사법정보공유포털(대법원 OpenAPI)** | https://openapi.scourt.go.kr/ ; 연계 API https://openapi.scourt.go.kr/kgso301m01.do ; 이용안내 https://openapi.scourt.go.kr/kgso202m01.do | 판례·사건정보 데이터 API + 기능 API(사실조회 회신 등) | | 회원가입·계약 필요, 이용 대상(기관 한정 여부) 미확인 — **키트에서 가장 먼저 검토할 공식 채널** |
| CaseNote | https://casenote.kr/ ; URL 패턴 `https://casenote.kr/대법원/2017다37324`, `https://casenote.kr/서울고등법원/2018나2002248` | 웹 UI, 400만+ 판결 | 대법원+하급심 광범위 | 무료 열람 제한·로그인, Pro 유료(사건번호로 판결문 요청). 약관상 자동화 불가 → 수동 교차확인용 |
| LBOX / 빅케이스 | https://lbox.kr/ ; https://bigcase.ai/cases/대법원/2017다37324 | 웹 UI | 하급심 포함 | 유료·약관 |
| AI허브 법률 데이터셋 | https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=580 ; https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=71723 | 다운로드(회원·승인) | 6만+ 판례 라벨링, 1만+ 판결문 기초사실·주장 가공 | 연구 목적 조건 확인 필요 |
| HuggingFace 미러 | https://huggingface.co/datasets/joonhok-exo-ai/korean_law_open_data_precedents | 다운로드 | 법제처 Open API 수집본 | 라이선스 확인 |
| 오픈소스 MCP | https://github.com/taendong/law-search ; korean-law-mcp https://glama.ai/mcp/servers/seo-jinseok/korean-law-mcp ; jurisupport 키 발급 가이드 https://github.com/jurisupport/jurisupport-plugins/blob/main/guides/07_law_openapi_key.md | | | |

### 5.2 법제처 Open API 요청 형식 (GitHub README + 기존 지식, **원문 가이드 재검증 필요**)
```
# 판례 목록
GET https://www.law.go.kr/DRF/lawSearch.do?OC={인증키}&target=prec&type=JSON
    &search=2            # 1=판례명, 2=본문
    &query=대여금         # 검색어
    &nb=2017다37324      # 사건번호 (정확 일치 검색 파라미터, 재검증)
    &org=400201          # 400201 대법원 / 400202 하급심
    &prncYd=20200101~20251231  # 선고일자 범위
    &display=100&page=1  # display 최대 100
# 판례 본문
GET https://www.law.go.kr/DRF/lawService.do?OC={인증키}&target=prec&type=JSON&ID={판례일련번호}
```
- 목록 응답 필드: 판례일련번호, 사건명, 사건번호, 선고일자, 법원명, 사건종류명, 판결유형, 선고, 판례상세링크.
- 본문 응답 필드: 판시사항, 판결요지, 참조조문, 참조판례, 판례내용(전문).
- 제약(README 확인): AND 검색은 단어별 상위 100건 교집합, 형태소 느슨 매칭, 일부 target은 XML만, OC 노출 방지 위해 프록시 권장, Referer 헤더 필요 사례.
- 사건부호 자료: 대법원 사건구분안내 https://www.scourt.go.kr/portal/information/event/guide/index.html ; 예규 https://www.lawnb.com/SubInfo/CaseSignHelp ; https://namu.wiki/w/사건번호

### 5.3 "사건번호로 존재 확인 → 요지 대조" 파이프라인 실현 가능성 평가
**결론: 부분적으로 구현 가능. 대법원 판례는 자동 검증 가능, 하급심은 자동 검증 불가(→ "미검증" 라벨링 후 인용 금지).**

```
입력: LLM 초안에 등장한 인용 "대법원 2018. 1. 24. 선고 2017다37324 판결"
1) 정규식 파싱: ^(19|20)\d{2}(가소|가단|가합|나|다|카단|카합|차|차전|머|타채|…)\d{1,7}$
   + 법원명·선고일 추출. 형식 불일치 → 즉시 폐기.
2) 법제처 Open API lawSearch(target=prec, nb=사건번호) → 0건이면 (query=사건번호, search=2)로 재시도.
3) 히트 시 lawService(ID)로 판결요지 획득 → 초안의 인용 요지와 임베딩 유사도/NLI 대조.
   불일치(요지 왜곡) → "판례는 존재하나 취지 불일치" 경고.
4) 0건이면 상태 = "UNVERIFIED". 자동으로 '존재하지 않음'이라 단정하지 말 것(하급심·미수록 가능).
   사용자에게 사법정보공개포털 '허위 사건번호 확인'(수동, 브라우저) 링크와
   판결서 인터넷열람(1,000원) 절차를 안내. UNVERIFIED 인용은 서면에서 자동 제거.
5) 검증 로그를 서면 말미 "AI 활용 고지" 블록에 첨부(§5.4 규칙 개정 대비).
```
- 근거 사례: 울산지법 대여금 사건에서 로펌 준비서면에 "대법원 2009다103436" 등 존재하지 않는 사건번호 인용(머니투데이 2026.5.12 https://www.mt.co.kr/society/2026/05/12/2026051120223293803); 서울북부지법·부산지법 즉결 사건에서 나홀로소송자 ChatGPT 허위 판례 인용(https://www.hankyung.com/article/2026040879471 , https://news.nate.com/view/20260318n34205); 판사들이 판결문에 "허위 판결·법원 기망" 명시(법률신문 https://www.lawtimes.co.kr/news/articleView.html?idxno=226218); 해외 사례 DB 한국 4건(https://www.lawtimes.co.kr/news/articleView.html?idxno=222424).

### 5.4 법원의 제도 대응(키트 설계 제약)
- 법원행정처 'AI 활용 허위 주장·증거 제출 대응 TF'(2025.11~) 결과 2026.3.31 공개: **민사소송규칙 개정 추진 — 소송서류에 AI 활용 사실 고지 + 인용 법령·판례 정확성 확인 의무**, 허위 인용 시 과태료 입법 제안, 변호사는 변협 징계 의뢰, 진술 제한·판결문 적시. https://www.lawtimes.co.kr/news/articleView.html?idxno=218596 ; https://www.koreancenter.or.kr/news/articleView.html?idxno=1332108 ; https://newsfn.co.kr/View.aspx?No=4189345 ; https://www.tsisalaw.com/news/article.html?no=29945
- 설계 함의: 키트 산출물 모든 서면 하단에 "본 서면은 생성형 AI 보조로 작성되었고, 인용 판례는 [검증 로그]로 확인함" 문구 템플릿 기본 포함.

---

## 6. 요건사실 자료 (대표 소액 사건 유형)

### 6.1 공개 자료 현황
| 자료 | 공개 여부 | URL |
|---|---|---|
| 사법연수원 『요건사실론』 교재 | **무료 PDF 없음**. 사법발전재단 구매(신청서·계좌이체). 2018판 정부간행물 | https://www.scourt.go.kr/portal/pds/foundation/index.html ; 알라딘 https://www.aladin.co.kr/shop/wproduct.aspx?ItemId=137903615 |
| 위키책 『요건사실론』 | 공개(CC). 대여금반환청구 항목 확인 | https://ko.wikibooks.org/wiki/요건사실론/대여금반환청구 |
| 공단 혼자하는 소송 > 유형별 요건사실 | 공개(웹) | https://support.klac.or.kr/front/contents/06/01003-01.do (주택임대차보증금 반환) 외 유형별 페이지 |
| 공단 법률서식작성방법(공공데이터) | 공개(파일) | https://www.data.go.kr/data/15142986/fileData.do |
| 법원도서관 | 판례·문헌 검색(법고을LX는 유료 DVD) | https://library.scourt.go.kr/ (미확인) |
| 대법원 판례속보(증명책임 판례) | 공개 | 급부부당이득 증명책임 https://www.scourt.go.kr/portal/news/NewsViewAction.work?pageIndex=1&searchWord=&searchOption=&seqnum=6020&gubun=4&type=5 ; 보증금 동시이행·무변론판결 https://www.scourt.go.kr/portal/news/NewsViewAction.work?pageIndex=1&searchWord=&searchOption=&gubun=4&type=5&seqnum=9179 |
| 상업 해설(보조) | | nepla 위키 https://www.nepla.ai/wiki/민사/… ; 로스쿨 요건사실 강의 자료 |

### 6.2 유형별 요건사실·입증책임 초안 (키트의 "요건사실 매칭" 룰 베이스 시드; 조문·판례는 재검증)
| 유형 | 원고 요건사실(주장·증명) | 전형적 항변(피고 증명) | 핵심 증거 | 시효 |
|---|---|---|---|---|
| **대여금** (민법 §598) | ① 금전소비대차 약정(반환 약정) ② 금전 교부(인도) ③ 변제기 도래(정함 없으면 상당기간 정한 최고) | 변제, 소멸시효, 상계, 증여(반환약정 부존재) | 차용증, 계좌이체 내역, 문자·카톡, 통화녹음, 일부변제 내역 | 민사 10년/상사 5년 |
| **물품대금** (민법 §563) | ① 매매계약 체결(목적물·대금 합의) ② 목적물 인도(이행) ③ 대금 미지급·변제기 | 하자·감액, 변제, **3년 단기시효(민법 §163 6호)**, 상계 | 발주서, 거래명세서, (전자)세금계산서, 납품확인서, 이메일 | **3년** |
| **임대차보증금 반환** (민법 §618, 주임법) | ① 임대차계약 체결 ② 보증금 지급 ③ 임대차 종료(기간만료·해지 통지) ④ (이행제공) 목적물 반환·반환 제공 | 동시이행항변(목적물 인도), 연체차임·원상회복비 공제, 보증금 일부 반환 | 계약서, 보증금 송금내역, 해지 통지(내용증명·문자), 퇴거·열쇠 반환 증빙, 관리비 정산 | 10년 |
| **손해배상(교통사고)** (민법 §750, 자배법 §3) | ① 가해행위(운행·과실) ② 위법성 ③ 손해(치료비·수리비·휴업·위자료) ④ 상당인과관계 | 과실상계, 보험처리 완료, 손해액 다툼 | 사고사실확인원, 블랙박스, 진단서·영수증, 견적서, 보험사 서류 | 3년(안 날)/10년 |
| **손해배상(명예훼손)** (민법 §750·§751) | ① 사실 적시(또는 모욕적 표현) ② 특정성 ③ 공연성(전파가능성) ④ 사회적 평가 저하 ⑤ 고의·과실 ⑥ 손해(위자료) | 진실성·공익성(위법성 조각), 공연성 부정 | 게시글 캡처(URL·시각), 공증·타임스탬프, 목격자 진술, 형사 처분결과 | 3년 |
| **임금** (근기법 §36·§43) | ① 근로계약(사용종속관계) ② 근로 제공 ③ 임금액·지급기일 ④ 미지급 | 지급 완료, 상계·공제, 시효 | 근로계약서, 급여명세서, 출퇴근기록, 통장, **체불임금등·사업주확인서**(노동청) | **3년** |
| **부당이득** (민법 §741) | 급부부당이득: ① 급부 ② 급부 원인의 무효·취소·해제 등 법률상 원인 없음(원고 증명, 대법원 2018.1.24. 2017다37324) ③ 손해·이득. 침해부당이득: 피고가 보유 권원 증명 | 법률상 원인(계약·증여), 비채변제(§742), 선의 수익자 현존이익 | 송금 착오 증빙, 계약 무효 근거 | 10년 |

근거 URL: 위키책 대여금 https://ko.wikibooks.org/wiki/요건사실론/대여금반환청구 ; 물품대금 시효 https://casenote.kr/법령/민법/제163조 , https://www.oneroadlaw.kr/sub/work/claim-for-goods-payment.php ; 보증금 판례 https://casenote.kr/대법원/2001다77697 , https://www.law.go.kr/LSW/precInfoP.do?precSeq=68198 ; 부당이득 https://casenote.kr/대법원/2017다37324 , https://www.lawtimes.co.kr/LawFirm-NewsLetter/141696 ; 임금 easylaw https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=1694&ccfNo=3&cciNo=4&cnpClsNo=2 , 노동부 https://labor.moel.go.kr/minwonSysInfo/wagesolway.do ; 명예훼손 공연성 https://www.law.go.kr/LSW/precInfoP.do?mode=0&precSeq=228491 , https://casenote.kr/대법원/2020도8336 ; 불법행위 §750 https://casenote.kr/법령/민법/제750조 ; 주택임대차 집행권원 easylaw https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=629&ccfNo=5&cciNo=2&cnpClsNo=3

---

## 7. 나홀로소송자의 흔한 시행착오 (법원·공단·언론)

| 시행착오 | 원인·결과 | 예방 규칙(키트) | 출처 |
|---|---|---|---|
| 소장 보정명령·각하 | 당사자 표시 불명확·누락, 청구취지 불특정(금액·이자 기산일·비율 미기재), 청구원인 불충분, 인지 미납 → 보정명령, 기간 내 미보정 시 소장 각하(민소법 §254) | 청구취지 템플릿 강제("피고는 원고에게 금 ○원 및 이에 대하여 20xx.x.x.부터 다 갚는 날까지 연 12%의 비율로 계산한 돈을 지급하라" + 소송비용 + 가집행), 인지·송달료 자동계산 | https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=5&cciNo=1&cnpClsNo=1 ; https://namu.wiki/w/보정명령 ; https://www.nepla.ai/wiki/민사/민사소송/소장의-기재사항/… |
| 당사자 특정 오류 | 피고 성명·주소·주민번호 오류 → 당사자표시정정, 송달 지연 | 인테이크에서 계약서·문자 상 피고 표시 대조, 법인은 등기부 확인 | https://www.lawhbd.com/expertise/?bmode=view&idx=163543217 |
| 관할 착오 | 피고 주소지만 생각하고 원거리 법원 제소 → 이송·출석 부담 | 민소법 §8 의무이행지(원고 주소지) 옵션 제시 | https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=239&ccfNo=2&cciNo=1&cnpClsNo=2 |
| 인지·송달료 부족 | 소가 산정 오류(이자 포함 여부, 병합청구), 전자소송 감액 착오 | 소가 산정 규칙(원금만, 부대청구 제외) 내장 | https://www.klac.or.kr/legalstruct/autoCostCalculation.do |
| 송달불능 | 수취인불명·이사불명 → 주소보정명령 → 미이행 시 각하 위험 | 주소보정 절차 가이드(주민번호 알면 포털 자동보정), 최후 공시송달 | https://www.easylaw.go.kr/CSP/OnhunqueansInfoRetrieve.laf?onhunqnaAstSeq=85&onhunqueSeq=1940 ; https://notturnoworld.com/…/셀프-전자소송-주소보정과-공시송달-신청/ |
| 증거 부족·정리 미흡 | 차용증 없이 "빌려줬다"만 주장, 카톡 캡처 무편집·시간 미표시, 갑호증 번호 누락 | 증거표(갑 제N호증·입증취지·요건사실 매핑) 자동 생성, 1회 변론 원칙에 맞춰 소장 단계에 전부 첨부 | https://www.daeryunlaw-discovery.com/info/747 ; easylaw 증거의 신청 https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=568&ccfNo=5&cciNo=3&cnpClsNo=3 |
| 기일 불출석 | 원고 2회 불출석 + 1개월 기일지정신청 없음 → 소취하 간주(§268); 피고 불출석 → 자백간주 | 전자송달 확인 알림, 기일변경신청서 안내 | https://albup.co.kr/page/column_detail.php?content_id=373 ; https://lfind.kr/cases/청주지방법원/2021가단64057 ; ecfs 기일의 진행 PSP730M05 |
| 답변서 기한 도과(피고) | 30일 내 미제출 → 무변론 패소 | 피고 모드: 송달일 기준 D-30 카운트다운 | https://casenote.kr/법령/민사소송법/제256조 |
| 이행권고결정 이의 기한 도과 | 2주 도과 시 확정 → 강제집행 | 피고 모드 D-14 알림 | https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=239&ccfNo=3&cciNo=1&cnpClsNo=1 |
| AI 가짜 판례 인용 | 존재하지 않는 사건번호·법리 → 재판부 신뢰 상실, 판결문 적시, 과태료 입법 추진 | §5.3 검증 파이프라인, 미검증 인용 자동 삭제 | https://www.hankyung.com/article/2026040879471 ; https://news.koreanbar.or.kr/news/articleView.html?idxno=36031 (40쪽 AI 서면) |
| 승소 후 집행 실패 | "이겼지만 못 받음": 재산 파악 없이 종료 | 재산명시·채권압류·추심명령(전자소송 PSP735M04) 후속 단계 안내 | https://brunch.co.kr/@sunwindntree/54 ; https://m.easylaw.go.kr/MOB/CsmInfoRetrieve.laf?csmSeq=239&ccfNo=3&cciNo=1&cnpClsNo=3 |
| 소권 남용 | 반복 제소·무익 소송 → 법원 제재 검토 | 승소가능성 낮을 때 조정·지급명령 우선 제안 | 사법정책연구원 보고서 https://jpri.scourt.go.kr/fileDownLoad.do?seq=2204 |

통계 맥락: 소액사건은 매년 **80% 이상 변호사 미선임**(2024 사법연감, 2019~2023) → 2025년 통계에서는 **97.5%**(법원행정처, 문화일보 https://www.munhwa.com/article/11588946); 2024년 소액사건 접수 507,804건(1심 민사본안 879,799건의 약 58%); 2026년 1~7월 소액 접수 334,674건(+12.7% YoY). https://www.fnnews.com/news/202503111338086842 ; https://www.lawtimes.co.kr/news/211723 ; https://www.legaltimes.co.kr/news/articleView.html?idxno=89375

---

## 8. 경쟁·유사 서비스

### 8.1 공공
| 서비스 | 내용 | URL |
|---|---|---|
| 대법원 소송절차 안내 AI 챗봇 | 민사·형사·가사·행정·집행 절차 24시간 안내(구 '스마트 소송 안내' 계열). 차세대 전자소송(2025.1)에서 챗봇·AI 유사판결 추천 | https://sjbot.scourt.go.kr/ ; https://www.lawtimes.co.kr/news/205130 ; https://www.hankookilbo.com/news/article/A2025013010540003649 |
| 법무부 **법률구조 플랫폼(helplaw24)** | 2026.1.21 개시, 35개 기관, AI 서비스 매칭·사례 답변·서식 안내, AI 콜센터 1661-3119 | https://www.helplaw24.go.kr/ ; https://www.korea.kr/news/policyNewsView.do?newsId=148958376 ; https://www.nongmin.com/article/20260122500448 |
| 법제처 지능형 법령검색(Lawbot) | 법령 Q&A | https://www.law.go.kr/ais/main.do |
| 공단 법률똑똑이 | 공단 챗봇 | https://klac.or.kr/startingChat.do?channelCd=CHATBOT |
| 찾기쉬운 생활법령정보 '나홀로 민사소송'·'소액사건재판' 책자형 | 절차 백과 | https://easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=1&cciNo=1&cnpClsNo=1 ; https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=239&ccfNo=1&cciNo=1&cnpClsNo=1 ; 주요법령 https://www.easylaw.go.kr/CSP/SysChartRetrievePLst.laf?csmSeq=568 |

### 8.2 민간 리걸테크
| 서비스 | 대상·가격 | 비고 | URL |
|---|---|---|---|
| 로톡(로앤컴퍼니) | 15분 전화상담 2~5만원, 20분 영상, 30분 방문; 가입 시 무료쿠폰 | 변호사 매칭 플랫폼. 변호사용 AI '슈퍼로이어' 월 99,000원(스탠더드)/198,000원(프로) — 일반인 불가 | https://www.lawtalk.co.kr/ ; https://www.lawtalk.co.kr/notices/14-로톡-15분-전화상담-이란 ; https://www.lawtimes.co.kr/news/199569 ; https://superlawyer1.imweb.me/pricing-yearly |
| 로앤굿 | 변호사 탐색·선임 플랫폼. 일반인 AI 챗봇(2023.5 국내 최초 ChatGPT 기반)은 2024.9경 내림; 비법조인용 '로앤서치' 운영 | 변협 규제 리스크 사례 | https://www.lawandgood.com/ ; https://lawandsearch.ai/ ; https://www.hankyung.com/article/2024091004131 ; https://www.aitimes.com/news/articleView.html?idxno=157736 |
| AI대륙아주(법무법인 대륙아주+넥서스AI) | 무료 AI 상담 챗봇 → 변협 징계 개시 → 서비스 중단(2024) | | https://www.hankyung.com/article/202409097812i ; https://edaily.co.kr/News/Read?mediaCodeNo=257&newsId=03588326639050952 |
| 알법, 로챗, 로로봇, 리걸AI 등 | 일반인 AI 법률상담 챗봇 | | https://albup.co.kr/ ; https://play.google.com/store/apps/details?id=com.rhqud.lawchat ; https://www.hellodd.com/news/articleView.html?idxno=106800 ; https://www.legalaicorp.com/ |
| 내용증명 자동작성 등 'AI 변호사' 류 | 2026.3 한경 보도 | | https://plus.hankyung.com/apps/newsinside.view?aid=2026031804331 |
| LBOX·CaseNote Pro·빅케이스 | 변호사용 판례 DB(유료) | | https://lbox.kr/ ; https://casenote.kr/pro/ ; https://bigcase.ai/ |

### 8.3 규제 환경(키트 포지셔닝의 핵심)
- **서울고법 2025누6423(2026.9)**: 정해진 질문에 사용자가 입력하면 AI가 문서를 생성하는 방식은 '표준화된 서식 제공'에 가까워 변호사법 위반 아님. 다만 개인 사정을 분석해 맞춤 법률판단을 더하거나 변호사 연결·소개를 하면 위반 소지. https://www.fnnews.com/news/202605251325014213 ; https://m.news.nate.com/view/20260525n09641 ; https://www.daeryunlaw.com/trend/10342
- 법무부는 2025.5 '변호사 검색서비스 운영 가이드라인' 이후 AI 법률서비스 가이드라인 미제정, 제도개선위 구성(2026.5). 
- 설계 함의: 키트는 (1) 공식 서식·법원 안내 자료의 구조화된 입력 폼, (2) 사용자가 입력한 사실을 요건사실 체크리스트에 **대조·표시**(판단 대신 "누락 항목" 표시), (3) 변호사 소개·수임 유도 없음, (4) 무료구조 대상 라우팅 — 이 4원칙으로 변호사법 리스크를 낮춘다.

### 8.4 서적
| 서명 | 저자/출판 | 가격 | URL |
|---|---|---|---|
| 혼자서 하는 나홀로 민사소송 | 김만기 / 법문북스 (전자책 있음) | 미확인 | https://product.kyobobook.co.kr/detail/S000001174514 ; https://www.yes24.com/product/goods/96246188 |
| 나홀로 소송, 당신도 승소 할 수 있다 | 이종섭 / 법문북스 | 19,000원 | https://product.kyobobook.co.kr/detail/S000201216802 ; https://www.yes24.com/Product/Goods/117950177 |
| 나홀로 민사소송 | 법제처 엮음 | 미확인 | https://www.aladin.co.kr/shop/wproduct.aspx?ItemId=50275752 |
| 나홀로 하는 민사소송실무 | 미확인 | 미확인 | https://www.aladin.co.kr/m/mproduct.aspx?ItemId=123018939 |
| 법원실무제요 민사소송 | 사법발전재단 | 고가(전문가용) | https://www.yes24.com/product/goods/60510703 |
| 요건사실론(2024, 신관악 민사법학회) | 글샘 | 미확인 | https://m.yes24.com/Goods/Detail/125554826 |

### 8.5 커뮤니티·유튜브·프롬프트 판매 (수집 한계 있음)
- 유튜브: '아는 변호사' https://www.youtube.com/@korealawyer2043 , '법무법인 테헤란 어토니' https://www.youtube.com/@thrattorney , 고운변호사(소장 작성) https://www.gounlaw.com/sns/youtube/39 , 법무법인 산우 https://sanwoolaw.com/youtube/ — **구독자 수·조회수는 확인 실패**.
- 블로그형 가이드: LawInUs '나홀로 소액 민사소송 무작정 따라하기'(소장작성 Ⅳ, 답변서·반소 Ⅴ, 소송제기 검토 Ⅱ) https://lawinus.co.kr/… ; 참지마요 법률칼럼 https://www.chamjimayo.com/ ; 로컴 '나홀로 소송, 나홀로가 아냐' https://www.lawcom.org/post/…
- 네이버 카페 '나홀로소송' 류: **검색 결과에서 카페명·회원수 확인 실패**(네이버 카페는 검색엔진 색인 제한). 한국망에서 직접 확인 필요.
- 유료 프롬프트 판매: 크몽에 ChatGPT 프롬프트 관련 서비스 1,060개+ 존재(https://kmong.com/article/1031-…), 법률 특화 소장 프롬프트 개별 상품은 **미확인**. Threads의 변호사 계정이 '법률 프롬프트 공개 시리즈'(12탄 고소장 작성 프롬프트)를 무료 배포 중 https://www.threads.com/@kim_lawyer/post/DKMjTSvhnkv . 크몽 대여금 소송 성공사례 콘텐츠 https://kmong.com/article/1580-…
- 언론이 포착한 사용자 행태: "AI 있으매 나홀로 소액소송 급증"(문화일보), "AI 쓴 서면으로 변호사 상대 승소"(YTN 2026.5 https://www.ytn.co.kr/_ln/0103_202605180510488951), 10대가 엄마 대리로 출석(머니투데이 https://www.mt.co.kr/society/2026/05/03/2026042409094434361), 변호사들 'AI 40쪽 서면' 검증 부담(법조신문).

---

## 9. 에이전트 워크플로 제안

각 단계는 "정부 자료를 인용해 사용자가 스스로 채우게 하는 폼" + "누락·불일치 체크"로 구성한다(§8.3 규제 원칙).

| # | 단계 | 에이전트가 하는 일 | 참조 정부 자료(URL) | 사용 서식명 |
|---|---|---|---|---|
| 0 | 게이트 | 소가 ≤ 3,000만원 여부, 금전청구 여부, 무료구조 대상(중위소득 125%, 임금체불 등) 여부 → 공단/helplaw24 라우팅 | 규칙 §1조의2 https://www.law.go.kr/LSW/lsInfoP.do?lsiSeq=52485 ; 공단 대상자 https://klac.or.kr/legalstruct/legalRescueGuide.do?codeValue=INC003 ; https://www.helplaw24.go.kr/ | — |
| 1 | 인테이크 인터뷰 | 사건유형 선택(대여금·물품대금·보증금·손해배상·임금·부당이득) → 유형별 질문 트리(당사자 특정 정보, 계약·이행·종료·미지급 사실, 상대방 주소·주민번호 인지 여부, 기존 독촉·내용증명) | easylaw 나홀로 민사소송 https://easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=1&cciNo=1&cnpClsNo=1 ; 공단 서식작성방법 https://www.data.go.kr/data/15142986/fileData.do | 인테이크 시트(자체) |
| 2 | 크로놀로지 | 날짜순 사실표(일자·사실·근거자료·상대방 반응). 소멸시효(3년/5년/10년) 자동 경고, 시효중단 조치(내용증명 6개월 내 제소) 제안 | 민법 §163 https://casenote.kr/법령/민법/제163조 ; 물품대금 시효 안내 https://www.oneroadlaw.kr/sub/work/claim-for-goods-payment.php | 사실관계 정리표(자체) |
| 3 | 요건사실 매칭 | §6.2 룰 베이스로 요건사실별 충족/미충족/증거 없음 표시. 예상 항변(동시이행·변제·시효) 사전 점검 | 공단 요건사실 페이지 https://support.klac.or.kr/front/contents/06/01003-01.do ; 위키책 https://ko.wikibooks.org/wiki/요건사실론/대여금반환청구 ; 대법원 판례속보(증명책임) | 요건사실 체크리스트(자체) |
| 4 | 증거표 | 갑 제N호증 번호 부여, 입증취지, 매핑된 요건사실, 원본/사본, 카톡·문자 캡처 규격(발신자·일시 포함), 진술서(서면증언) 필요 여부 | easylaw 증거의 신청·조사 https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=568&ccfNo=5&cciNo=3&cnpClsNo=3 ; 소액사건심판법 §10 https://casenote.kr/법령/소액사건심판법/제10조 | 증거설명서, 증인(서면)진술서, 사실조회신청서, 문서제출명령신청서(양식모음 PSP720M24) |
| 5 | 소장 초안 | 관할(§8 의무이행지 옵션) 선택, 청구취지 템플릿(원금+지연이자 연 12% 소촉법 기산일=소장부본 송달 다음날), 청구원인을 요건사실 순으로 서술, 입증방법·첨부서류 목록. 판례 인용은 §5.3 검증 통과분만 | 소장 대표유형 https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M01 ; 소장작성방법 https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=4&cciNo=1&cnpClsNo=1 ; 관할 https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=239&ccfNo=2&cciNo=1&cnpClsNo=2 | 소장(대여금·물품대금·임대차보증금반환·손해배상·임금·부당이득금 청구) / 대안: 지급명령신청서, 조정신청서 |
| 6 | 인지·송달료 계산 | 소가 산정(원금만) → §4.4 인지식(전자 10% 감액) → 송달료 5,500×당사자수×10회. 지급명령(1/10, 6회)·조정(1/10, 5회) 비교표 제시 | 인지액 계산방법 https://ecfs.scourt.go.kr/psp/link.on?m=PSP007P01 ; 공단 자동계산 https://www.klac.or.kr/legalstruct/autoCostCalculation.do ; easylaw 인지·송달료 https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=568&ccfNo=2&cciNo=4&cnpClsNo=3 | 소송비용 계산서(자체) |
| 7 | 전자소송 제출 체크리스트 | 회원가입·인증서 → 전자소송 동의 → 사건기본정보 → 당사자 → 청구취지/원인 → 입증서류 등록·저장 → 첨부서류 → 비용납부 → 전자서명. 제출 후 사건번호 기록, 송달 알림 설정, 주소보정 대비(피고 주민번호 확보) | 전자소송이용안내 https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M03 ; 민사본안 제출 https://ecfs.scourt.go.kr/psp/index.on?m=PSPA13M01 ; 인증서 https://ecfs.scourt.go.kr/psp/index.on?m=PSP720M02 ; 주소보정 https://www.easylaw.go.kr/CSP/OnhunqueansInfoRetrieve.laf?onhunqnaAstSeq=85&onhunqueSeq=1940 | 제출 체크리스트(자체), 주소보정서, 공시송달신청서 |
| 8 | 답변서·준비서면 대응 | 원고 모드: 피고 답변서 수령 시 항변 분류(부인/항변) → 재항변 요건사실·추가 증거 → 준비서면 초안. 피고 모드: 소장·이행권고결정 수령 D-30/D-14 알림, 답변서(청구취지 답변·청구원인 답변·항변) 초안, 이의신청서 | 피고의 대응(지급명령 이의) https://ecfs.scourt.go.kr/psp/index.on?m=PSPJ02M06 ; 민소법 §256·§257 https://casenote.kr/법령/민사소송법/제256조 ; 이행권고결정 https://www.easylaw.go.kr/CSP/CnpClsMain.laf?csmSeq=239&ccfNo=3&cciNo=1&cnpClsNo=1 ; LawInUs 답변서·반소 https://lawinus.co.kr/… | 답변서, 준비서면, 이행권고결정 이의신청서, 지급명령 이의신청서, 반소장 |
| 9 | 기일 준비 | 1회 변론 종결 전제: 쟁점 정리 메모, 증거 원본 지참 목록, 예상 질문(판사·상대방) Q&A, 조정 권유 시 수용 기준(금액·분할), 불출석 리스크 안내, 기일변경신청 요건 | 기일의 준비 https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M04 ; 기일의 진행 https://ecfs.scourt.go.kr/psp/index.on?m=PSP730M05 ; 소액사건 심리 https://easylaw.go.kr/CSP/CnpClsMain.laf?popMenu=ov&csmSeq=239&ccfNo=4&cciNo=1&cnpClsNo=2 ; 나의사건검색 https://ssgo.scourt.go.kr/ | 변론 메모(자체), 기일변경신청서, 증거설명서 |
| 10 | (후속) 집행 | 확정(이행권고결정·판결) 후 미이행 시 재산명시신청, 채권압류·추심명령(예금·급여·보증금) 안내 | 채권 강제집행 https://ecfs.scourt.go.kr/psp/index.on?m=PSP735M04 ; 이행권고결정 강제집행 특례 https://m.easylaw.go.kr/MOB/CsmInfoRetrieve.laf?csmSeq=239&ccfNo=3&cciNo=1&cnpClsNo=3 | 채권압류 및 추심명령신청서, 재산명시신청서 |
| ∞ | 횡단 기능 | 판례 검증 파이프라인(§5.3), AI 활용 고지 블록(§5.4), 공단 라우팅(§3.2), 기한 알림(답변서 30일·이의 2주·불출석 1개월) | 사법정보공개포털 허위 사건번호 확인 https://portal.scourt.go.kr/pgp/index.on?m=PGP210M01&l=N&c=200 ; 법제처 Open API https://open.law.go.kr/LSO/openApi/guideResult.do?htmlName=precListGuide | 검증 로그(자체) |

---

## 10. 한국망에서의 재검증 체크리스트 (우선순위순)
1. 전자소송포털 양식모음(PSP720M24)에서 소장·답변서·준비서면·지급명령신청서·이행권고결정 이의신청서 HWP 다운로드 → 필드 스키마화.
2. 법제처 Open API 가이드(precListGuide/precInfoGuide) 원문에서 `nb`(사건번호)·`org`·`search` 파라미터 명칭과 일일 호출 한도 확인; OC 발급 후 "2017다37324" 실호출 테스트.
3. 사법정보공유포털(openapi.scourt.go.kr) 판례·사건정보 API의 개인 개발자 이용 가능 여부·계약 조건.
4. 송달료 별표 1(단독 15회·항소 12회) 및 인지법 전자소송 감액 조문 번호.
5. 공단 support.klac.or.kr 유형별 요건사실 페이지 전수 URL(dirId/contentId) 수집.
6. 2025 기준 중위소득 125% 표(스니펫 수치 상충).
7. 네이버 카페·유튜브 채널 규모, 크몽 법률 프롬프트 상품 실재 여부.
8. 서울고법 2025누6423 판결문 원문(변호사법 판단 기준 문구).
