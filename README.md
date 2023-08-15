# Otimização Android TV (TCL)
* Lembrando que esse aplicativo é apenas para TVs TCL com Android TV, não para Mi Box.
* Aplicativo 100% compatível com o [Termux](https://f-droid.org/en/packages/com.termux).

Esse aplicativo tem a finalidade de realizar otimizações em TVs TCL que rodam Android, removendo aplicativos lixo (Russo, Indiano, Australiano e Chinês), dentre outros que só estão presente na TV para deixar ela mais inchada e lerda. Também realiza a instalação de um novo Laucher otimizado e alguns apps.

## Dependências
* adb
* fakeroot (Termux)

## Instalar
Termux:
```
curl -L https://github.com/Krush206/optimize_android_tv/raw/java/OTT_Android.jar ; chmod +x OTT_Android.jar
```
Linux:
```
curl -L https://github.com/Krush206/optimize_android_tv/raw/java/OTT_Linux.jar ; chmod +x OTT_Linux.jar
```

## Executar
Termux:
```
dalvikvm -cp OTT_Android.jar OTT.Main
```
Linux:
```
java -jar OTT_Linux.jar
```

![](https://user-images.githubusercontent.com/981368/164873999-f7318e15-7b8e-42fa-b1fd-71ee4505753d.png)
