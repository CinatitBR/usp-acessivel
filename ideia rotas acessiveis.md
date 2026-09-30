TODO REFATORAÇÃO

## Add interface for user to create map reports.
- When the user taps

- When user taps on the "create report" button, the app should open a bottom sheet with the report creation interface.
- In this interface, the user should be able to:
  - Choose the type of report:
    - imperfeição na via (buraco, raízes de árvores, calçada quebrada): aquilo que dificulta a locomoção
    - problema de acessibilidade: entrada inacessível (entrada sem rampa, por exemplo), andar do prédio inacessível (acesso somente com escada e sem elevador, por exemplo. esse tipo de reporte idealmente tem que estar associado a algum prédio no mapa), elevador quebrado ou pequeno demais (pode não caber cadeirantes), banheiro inacessível (por exemplo, não há banheiro acessível no prédio para cadeirantes)
  - Choose the severity of the report (only for imperfeição na via):
    - moderada
    - severa
  - Add a description of the report
  - Add a photo of the report
  - Submit the report

Surface problems: buraco, calçada quebrada, raíz de árvore quebrando a calçada, piso escorregadio, inclinação excessiva
-------------
 
Reportes que devem ser feitos:
- Imperfeição na via: buraco, superfície irregular (irregularidade causada, por exemplo, por raízes de árvores. Uma escada que é muito grande e com degraus quebrados), calçada estreita. Esse tipo de reporte possui severidade: moderado, severo. 

- Problema de acessibilidade: entrada inacessível (entrada sem rampa, por exemplo), andar do prédio inacessível (acesso somente com escada e sem elevador, por exemplo. esse tipo de reporte idealmente tem que estar associado a algum prédio no mapa), elevador quebrado ou pequeno demais (pode não caber cadeirantes), banheiro inacessível (por exemplo, não há banheiro acessível no prédio para cadeirantes)

- Ideia: criar nosso próprio rating system de acessibilidade para cada prédio (estilo wheelmap). Convocar pessoas PCD para ajudar a criar esse sistema. Podemos usar cores: verde, laranja, vermelho, cinza.
