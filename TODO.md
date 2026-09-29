# IDEIA: Reportar informações sobre o mapa do campus utilizando um arquivo md.
Um arquivo md é utilizado para descrever todo tipo de informações sobre o mapa.

## Exemplos
Associar uma descrição a uma avenida:
```md
# Nome da avenida
Avenida Professor Lineu Prestes

# Descrição
Possui uma série de imperfeições ao longo da calçada, causadas por raízes de árvores. Pode ser difícil caminhar.
```

Associar uma descrição a um ponto de ônibus:
```md
# Ponto de ônibus
- Ponto da Biblioteca Central
- Ponto da Física
- Ponto da Poli

## Descrição
Nessa semana, os ônibus têm demorado demais para passar no período da tarde.

```

Associar uma descrição a um prédio:
```md
# Tipo da Informação
- Acessibilidade

# Prédio
- IME

## Descrição
O Bloco B do IME, local onde ocorre a maioria das aulas, não possui elevador que leva até o primeiro andar,
o que pode impedir pessoas com mobilidade reduzida de acessarem algumas salas.

```

Associar informações a um trecho de uma rua (construção da calçada):
```md
# Rua
- Avenida Professor Lineu Prestes

## Descrição
Há obras no trecho inicial da avenida.
```

Associar informações a um trecho de uma rua (iluminação):
```md
# Rua
- Avenida Professor Lineu Prestes

## Descrição
Por conta das obras, essa região tem tido uma iluminação ruim.

```

Associar informações a um trecho de uma rua (construção da calçada):
```md
# Rua
- Avenida Professor Lineu Prestes

## Descrição
Há obras no trecho inicial da avenida.
```

Associar informação a uma escada externa:
```md
# Rua
- Avenida Professor Lineu Prestes

## Descrição
A escadaria que leva até o bandejão da química é longa e íngrime, com degraus estreitos e corrimão defeituoso.
```

----------------
# Update "create_poi_page.dart" to follow the visual scheme of "create_visual_route_page.dart".

- Update the inputs and section titles.

---

new: com.github.cinatitbr.usp_acessivel
old: com.example.meu_campus_flutter

---