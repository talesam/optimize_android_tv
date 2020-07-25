#!/usr/bin/env bash
# Otimizações Android TV
# Por Tales A. Mendonça - talesam@gmail.com
# Agradecimento ao Bruno Gonçalvez Araujo, BigBruno, por algumas contribuições no código
# https://developer.android.com/studio/command-line/adb
# https://adbshell.com/commands/adb-shell-pm-list-packages

# Versão do script
VER="v0.0.26"

# Definição de Cores
# Tabela de cores: https://misc.flogisoft.com/_media/bash/colors_format/256_colors_fg.png

# Cores degrade
RED001='\e[38;5;1m'		# Vermelho 1
CYA122='\e[38;5;122m'	# Ciano 122
CYA044='\e[38;5;44m'	# Ciano 44
ROX063='\e[38;5;63m'	# Roxo 63
ROX027='\e[38;5;27m'	# Roxo 27
GRE046='\e[38;5;46m'	# Verde 46
GRY247='\e[38;5;247m'	# Cinza 247
LAR208='\e[38;5;208m'	# Laranja 208
LAR214='\e[38;5;214m'	# Laranja 214
AMA226='\e[38;5;226m'	# Amarelo 226
MAR094='\e[38;5;94m'	# Marrom 94
MAR136='\e[38;5;136m'	# Marrom 136

# Cores chapadas
CIN='\e[30;1m'			# Cinza
RED='\e[31;1m'			# Vermelho
GRE='\e[32;1m'			# Verde
YEL='\e[33;1m'			# Amarelo
BLU='\e[34;1m'			# Azul
ROS='\e[35;1m'			# Rosa
CYA='\e[36;1m'			# Ciano
NEG='\e[37;1m'			# Negrito
CUI='\e[40;31;5m'		# Vermelho pisacando, aviso!
STD='\e[m'				# Fechamento de cor

# --- Início Funções ---

# Separação com cor
separacao(){
	for i in {16..21} {21..16} ; do
		echo -en "\e[38;5;${i}m____\e[0m"
	done ; echo
}

# Função pause
pause(){
   read -p "$*"
}

# Verifica se está usando Termux
termux(){
	clear
	echo -e " ${NEG}Bem vindo(a) ao script OTT (Otimização TV TCL)${STD}"
	echo -e " ${NEG}Modelos compatíveis: P8M, S6500 e S5300.${STD}"
	separacao
	echo ""
	echo -e " ${ROX063}Verificando dependências, aguarde...${STD}" && sleep 2
	if [ -e "/data/data/com.termux/files/usr/bin/adb.bin" ] || [ -e "/usr/bin/adb" ]; then
		echo -e " ${GRE046}Dependencias encontradas, conecte-se na TV.${STD}"
		pause " Tecle [Enter] para continuar..." ; conectar_tv
	else
		echo " Baixando dependências para utilizar o script no Termux"
		echo " Nas pŕoximas telas, tecle [Y], quando necessário, para continuar..." ; sleep 2
		apt update && apt install wget && wget https://raw.githubusercontent.com/MasterDevX/Termux-ADB/master/InstallTools.sh && bash InstallTools.sh && clear
		if [ "$?" -eq 0 ]; then
			echo "Instalação conluida com sucesso!"
			pause " Tecle [Enter] para se conectar a TV..." ; conectar_tv
		else
			echo " Erro ao baixar e instalar as dependências"
			echo " Verifique sua conexão e tente novamente." ; exit 0
		fi
	fi
}

# Conexão da TV
conectar_tv(){
	clear
	echo " Digite o endereço IP da sua TV que encontra no"
	echo " caminho abaixo e tecle [Enter] para continuar:"
	echo ""
	echo -e " ${AMA226}Configurações${STD}, ${AMA226}Preferências do dispositivo${STD},"
	echo -e " ${AMA226}Sobre${STD}, ${AMA226}Status${STD}."
	read IP

	ping -c 1 $IP >/dev/null
	# Testa se a TV está ligada com o modo depuração ativo
	if [ "$?" -eq 0 ]; then
		echo ""
		echo -e " ${LAR214}Conectando-se a sua TV...${STD}" && sleep 3
		adb connect $IP >/dev/null
		if [ "$?" -eq 0 ]; then
			echo -e " ${GRE046}Conectado com sucesso a TV!${STD}" && sleep 3 ; menu_principal
			echo ""
		else
			echo -e "  ${RED}*${STD} Erro! Falha na conexão, Verifique seu endereço de IP"
			pause "Tecle [Enter] para tentar novamente..." ; conectar_tv
		fi
	else
			echo -e "  ${RED}*${STD} Erro! Falha na conexão, Verifique seu endereço de IP"
			pause "Tecle [Enter] para tentar novamente..." ; conectar_tv
	fi
}

# Remover apps P8M
rm_apps_p8m(){
	clear
	OIFS=$IFS
	IFS=$'\n'
	# Verifica se o arquivo existe
	if [ -e "rm_apps_p8m.list" ]; then
		for app_rm in $(cat rm_apps_p8m.list); do
			adb shell pm uninstall --user 0 $app_rm >/dev/null
			if [ "$?" -eq 0 ]; then
				echo -e "  ${BLU}*${STD} App ${CYA}$app_rm${STD} ${GRE046}removido com sucesso!${STD}" && sleep 1
			else
				echo -e "  ${RED}*${STD} App ${CYA}$app_rm${STD} já foi removido ou não existe" && sleep 1
			fi
		done
	else
		# Baixar lista lixo dos apps
		echo "Aguarde, baixando lista negra de apps..." && sleep 1
		wget https://raw.githubusercontent.com/talesam/optimize_android_tv/master/rm_apps_p8m.list && clear
		if [ -e "rm_apps_p8m.list" ]; then
			for app_rm in $(cat rm_apps_p8m.list); do
				adb shell pm uninstall --user 0 $app_rm >/dev/null
				if [ "$?" -eq 0 ]; then
					echo -e "  ${BLU}*${STD} App ${CYA}$app_rm${STD} ${GRE046}removido com sucesso!${STD}" && sleep 1
				else
					echo -e "  ${RED}*${STD} App ${CYA}$app_rm${STD} já foi removido ou não existe" && sleep 1
				fi
			done
		else
			echo "Erro ao baixar a lista LIXO dos apps. Verifique sua conexão."
		fi
	fi
	echo ""
	pause " Tecle [Enter] para retornar ao menu principal..." ; menu_principal
IFS=$OIFS
}

# Remover apps S6500
rm_apps_S6500(){
	clear
	OIFS=$IFS
	IFS=$'\n'
	# Verifica se o arquivo existe
	if [ -e "rm_apps_S6500.list" ]; then
		for app_rm in $(cat rm_apps_S6500.list); do
			adb shell pm uninstall --user 0 $app_rm >/dev/null
			if [ "$?" -eq 0 ]; then
				echo -e "  ${BLU}*${STD} App ${CYA}$app_rm${STD} ${GRE046}removido com sucesso!${STD}" && sleep 1
			else
				echo -e "  ${RED}*${STD} App ${CYA}$app_rm${STD} já foi removido ou não existe" && sleep 1
			fi
		done
	else
		# Baixar lista lixo dos apps
		echo "Aguarde, baixando lista negra de apps..." && sleep 1
		wget https://raw.githubusercontent.com/talesam/optimize_android_tv/master/rm_apps_S6500.list && clear
		if [ -e "rm_apps_S6500.list" ]; then
			for app_rm in $(cat rm_apps_S6500.list); do
				adb shell pm uninstall --user 0 $app_rm >/dev/null
				if [ "$?" -eq 0 ]; then
					echo -e "  ${BLU}*${STD} App ${CYA}$app_rm${STD} ${GRE046}removido com sucesso!${STD}" && sleep 1
				else
					echo -e "  ${RED}*${STD} App ${CYA}$app_rm${STD} já foi removido ou não existe" && sleep 1
				fi
			done
		else
			echo "Erro ao baixar a lista LIXO dos apps. Verifique sua conexão."
		fi
	fi
	echo ""
	pause " Tecle [Enter] para retornar ao menu principal..." ; menu_principal
IFS=$OIFS
}

# Desativar/Ativar Apps - INICIO
COLS=$(tput cols)

ativar() {
	tput clear
	
	OIFS=$IFS
	IFS=$'\n'
	
	apk_disabled="$(adb shell pm list packages -d | cut -f2 -d:)"
	# Verifica se o arquivo existe no diretório local
	if [ -e "apps_disable.list" ]; then
		for apk_full in $(cat apps_disable.list); do
			apk="$(echo "$apk_full" | cut -f1 -d"|")"
			apk_desc="$(echo "$apk_full" | cut -f2 -d"|")"
			if [ "$(echo "$apk_disabled" | grep "$apk")" != "" ]; then
					echo -e "\n$(linha)\n"${ROX027}" $apk_desc"${STD}"\n\"$apk\"\n Digite ${GRE046}S${STD}(Sim) para ${GRE046}ATIVAR${STD} ou ${GRY247}N${STD}(Não) para manter ${GRY247}DESATIVADO${STD}"
				pergunta_ativar
			fi
		done
	else
		# Baixar lista de apps para serem desativados
		echo "Aguarde, baixando lista de apps..." && sleep 1
		wget https://raw.githubusercontent.com/talesam/optimize_android_tv/master/apps_disable.list
		if [ -e "apps_disable.list" ]; then
			for apk_full in $(cat apps_disable.list); do
				apk="$(echo "$apk_full" | cut -f1 -d"|")"
				apk_desc="$(echo "$apk_full" | cut -f2 -d"|")"
				if [ "$(echo "$apk_disabled" | grep "$apk")" = "" ]; then
					echo -e "\n$(linha)\n"${ROX027}" $apk_desc"${STD}"\n\"$apk\"\n Digite ${GRE046}S${STD}(Sim) para ${GRE046}ATIVAR${STD} ou ${GRY247}N${STD}(Não) para manter ${GRY247}DESATIVADO${STD}"
					pergunta_ativar
				fi
			done
		else
			echo "Erro ao baixar a lista de apps. Verifique sua conexão."
			pause " Tecle [Enter] para retornar ao menu principal..." ; menu_principal
		fi
	fi
	IFS=$OIFS
}

pergunta_ativar() {
	read -p " [S/N]: " -e -n1 resposta
	echo -e "$(linha)\n"
	[[ $resposta != +(s|S|n|N) ]] && pergunta_ativar || resposta_ativar
}

resposta_ativar() {
	[[ "$resposta" =~ ^([Ss])$ ]] && { echo -e ""${LAR208}"Informação sobre o pacote${STD} ${CYA044}${apk}${STD}";adb shell pm enable ${apk};}
}

desativar() {
	tput clear
	
	OIFS=$IFS
	IFS=$'\n'
	
	apk_disabled="$(adb shell pm list packages -d | cut -f2 -d:)"
	# Verifica se o arquivo existe no diretório local
	if [ -e "apps_disable.list" ]; then
		for apk_full in $(cat apps_disable.list); do
			apk="$(echo "$apk_full" | cut -f1 -d"|")"
			apk_desc="$(echo "$apk_full" | cut -f2 -d"|")"
			if [ "$(echo "$apk_disabled" | grep "$apk")" = "" ]; then
				echo -e "\n$(linha)\n"${ROX027}" $apk_desc"${STD}"\n\"$apk\"\n Digite ${GRY247}S${STD}(Sim) para ${GRY247}DESATIVAR${STD} ou ${GRE046}N${STD}(Não) para manter ${GRE046}ATIVO${STD}"
				pergunta_desativar
			fi
		done
	else
		# Baixar lista de apps para serem desativados
		echo "Aguarde, baixando lista de apps..." && sleep 1
		wget https://raw.githubusercontent.com/talesam/optimize_android_tv/master/apps_disable.list
		if [ -e "apps_disable.list" ]; then
			for apk_full in $(cat apps_disable.list); do
				apk="$(echo "$apk_full" | cut -f1 -d"|")"
				apk_desc="$(echo "$apk_full" | cut -f2 -d"|")"
				if [ "$(echo "$apk_disabled" | grep "$apk")" = "" ]; then
					echo -e "\n$(linha)\n"${ROX027}" $apk_desc"${STD}"\n\"$apk\"\n Digite ${GRY247}S${STD}(Sim) para ${GRY247}DESATIVAR${STD} ou ${GRE046}N${STD}(Não) para manter ${GRE046}ATIVO${STD}"
					pergunta_desativar
				fi
			done
		else
			echo "Erro ao baixar a lista de apps. Verifique sua conexão."
			pause " Tecle [Enter] para retornar ao menu principal..." ; menu_principal
		fi
	fi
	IFS=$OIFS
}

pergunta_desativar() {
	read -p " [S/N]: " -e -n1 resposta
	echo -e "$(linha)\n"
	[[ $resposta != +(s|S|n|N) ]] && pergunta_desativar || resposta_desativar
}

resposta_desativar() {
	[[ "$resposta" =~ ^([Ss])$ ]] && { echo -e ""${LAR208}"Informação sobre o pacote${STD} ${CYA044}${apk}${STD}";adb shell pm disable-user --user 0 ${apk};}
}

linha() {
	printf '%*s' "$COLS" '' | sed "s/ /_/g"
}
# Desativar/Ativar Apps - FIM

# Instalar e ativar Laucher ATV Pro TCL Mod + Widget
install_laucher(){
	# Remove versão do ATV PRO
	if [ "$(adb shell pm list packages -u | cut -f2 -d: | grep ca.dstudio.atvlauncher.pro)" != "" ]; then
		echo "Removendo versão do Laucher ATV PRO..." && sleep 1
		adb shell pm uninstall --user 0 ca.dstudio.atvlauncher.pro
		if [ "$?" -eq 0 ]; then
			echo "Laucher ATV PRO removido com sucesso!"
		else
			echo "Você não possui o Laucher ATV PRO instalado."
			pause "Tecle [Enter] para continuar com a instalação..."
		fi
	fi

	# Remove versão do ATV FREE
	if [ "$(adb shell pm list packages -u | cut -f2 -d: | grep ca.dstudio.atvlauncher.pro)" != "" ]; then
		echo "Removendo versão do Laucher ATV FRE..." && sleep 1
		adb shell pm uninstall --user 0 ca.dstudio.atvlauncher.free
		if [ "$?" -eq 0 ]; then
			echo "Laucher ATV PRO removido com sucesso!"
		else
			echo "Você não possui o Laucher ATV FRE instalado."
			pause "Tecle [Enter] para continuar com a instalação..."
		fi
	fi

	if [ "$(adb shell pm list packages -u | cut -f2 -d: | grep com.tcl.home)" != "" ]; then
		if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.tcl.home)" = "" ]; then
			echo "Ativando Laucher ATV PRO MOD..." && sleep 1
			adb shell pm enable com.tcl.home
			if [ "$?" -eq 0 ]; then
				# Desativa o laucher padrão
				adb shell pm disable-user --user 0 com.google.android.tvlauncher
				if [ "$(adb shell pm disable-user --user 0 com.google.android.tvlauncher | grep disabled-user | cut -f5 -d " ")" = "disabled-user" ]; then
					echo "Laucher ATV PRO MOD ativo com sucesso!"
					echo ""
					echo "Iniciando a nova Laucher ATV PRO MOD..." && sleep 2
					adb shell monkey -p com.tcl.home -c android.intent.category.LAUNCHER 1
					if [ "$?" -eq 0 ]; then
						echo "Laucher ATV PRO MOD iniciada com sucesso!" && sleep 1
						echo "Atualizando as permissões..."
						# Seta permissão para o widget
						adb shell appwidget grantbind --package com.tcl.home --user 0
						if [ "$?" -eq 0 ]; then
							echo "Permissões atualizadas com sucesso!"
						else
							pause "Erro ao ativar o Laucher, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
						fi
					else
						pause "Erro ao ativar o Laucher, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
					fi
				else
					pause "Erro ao ativar o Laucher, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
				fi
			else
				pause "Erro ao ativar Laucher ATV MOD. Tecle [Enter] para retornar ao menu" ; menu_laucher
			fi	
		fi
	else
		echo "Aguarde a instalação do novo Laucher ATV PRO MOD..." && sleep 2
		# Baixa o Laucher ATV PRO modificado e o Widget
		echo "Baixando a versão mais recente do Laucher ATV PRO MOD e Widget..."
		wget --content-disposition https://cloud.talesam.org/s/ZMz79soxAa7MYii/download
		wget --content-disposition https://cloud.talesam.org/s/S8tJqBiiKmog4wt/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o novo Laucher, aguarde..."
			adb install -r tclhome.apk
			adb install -r chronus.apk
			#if [ "$(adb install -r tclhome.apk | grep "Success")" = "Success" && "$(adb install -r chronus.apk | grep "Success")" = "Success" ]; then
			if [ "$?" -eq 0 ]; then
				echo "Laucher ATV PRO MOD instalado com sucesso!"
				echo "Ativando o novo Laucher, aguarde..." && sleep 2
				# Desativa o laucher padrão
				adb shell pm disable-user --user 0 com.google.android.tvlauncher
				if [ "$(adb shell pm disable-user --user 0 com.google.android.tvlauncher | grep disabled-user | cut -f5 -d " ")" = "disabled-user" ]; then
					echo "Laucher ATV PRO MOD ativo com sucesso!"
					echo "Ativando a nova Laucher ATV PRO MOD..." && sleep 2
					adb shell monkey -p com.tcl.home -c android.intent.category.LAUNCHER 1
					if [ "$?" -eq 0 ]; then
						echo "Laucher ATV PRO MOD ativado com sucesso!"
						echo "Abrindo Laucher ATV PRO MOD..." && sleep 1
					else
						pause "Erro ao ativar o Laucher ATV PRO, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
					fi
				else
					pause "Erro ao ativar o Laucher ATV PRO, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
				fi
				echo "Atualizando as permissões..."
				# Seta permissão para o widget
				adb shell appwidget grantbind --package com.tcl.home --user 0
				if [ "$?" -ne 0 ]; then
					pause "Erro ao setar permissões, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
				else
					echo "Permissões atualizadas com sucesso!"
				fi
			else
				pause "Erro na instalação.. Tecle [Enter] para continuar." ; menu_laucher
			fi
		fi
	fi
}

# Desativar Laucher ATV Pro TCL Mod + Widget
desativar_laucher(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.tcl.home)" != "" ]; then
		adb shell pm enable com.google.android.tvlauncher
		if [ "$(adb shell pm enable com.google.android.tvlauncher | grep enable | cut -f5 -d " ")" = "enable" ]; then
			adb shell am start -n com.google.android.tvlauncher/.MainActivity
			if [ "$?" -qe 0 ]; then
				echo "Configurado o Laucher padrão do Android TV com sucesso!"
			else
				pause "Erro abrir o Laucher padrão, verifique sua conexão. Tecle [Enter] para continuar." ; menu_laucher
			fi
		else
			echo "Seu Laucher ATV PRO MOD já está desativado."
			pause "Tecle [Enter] para retornar ao menu" ; menu_laucher
		fi
	else
		echo "Laucher ATV PRO MOD ainda não instalado."
	fi
	menu_laucher
}


# --- INSTALAR NOVOS APPS - INÍCIO

# Instalar Aptoide TV
install_aptoidetv(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep cm.aptoidetv.pt)" != "" ]; then
		echo "Aptoide TV já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Apdoide TV
		echo "Baixando Aptoide TV..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/j5ZbDP5yL2DAT9J/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Aptoide TV, aguarde..."
			adb install -r aptoide.apk
			if [ "$?" -eq 0 ]; then
				echo "Aptoide TV instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar Deezer MOD
install_deezermod(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep deezer.android.tv)" != "" ]; then
		echo "Deezer MOD já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Apdoide TV
		echo "Baixando Deezer MOD..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/8eBw4HGZryFyssf/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Deezer MOD, aguarde..."
			adb install -r deezer.apk
			if [ "$?" -eq 0 ]; then
				echo "Deezer MOD instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar Spotify
install_spotify(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.spotify.tv.android)" != "" ]; then
		echo "Spotify já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Spotify
		echo "Baixando Spotify..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/t8w48i6px9b4FfZ/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Spotify, aguarde..."
			adb install -r spotify.apk
			if [ "$?" -eq 0 ]; then
				echo "Spotify instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar TV Bro
install_tvbro(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.phlox.tvwebbrowser)" != "" ]; then
		echo "TV Bro já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o TV Bro
		echo "Baixando TV Bro..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/SSC5C4QrPN7BzqZ/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o TV Bro, aguarde..."
			adb install -r tvbro.apk
			if [ "$?" -eq 0 ]; then
				echo "TV Bro instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar Smart Youtube
install_smartyoutube(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.liskovsoft.videomanager)" != "" ]; then
		echo "Smart Youtube já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Smart Youtube
		echo "Baixando Smart Youtube..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/2S86QiiEm3ET8ss/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Smart Youtube, aguarde..."
			adb install -r smartyoutube.apk
			if [ "$?" -eq 0 ]; then
				echo "Smart Youtube instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar Send Files
install_sendfiles(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.yablio.sendfilestotv)" != "" ]; then
		echo "Send Files já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Send Files
		echo "Baixando Send Files..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/NwHy9Fe3AxYNLrL/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Send Files, aguarde..."
			adb install -r sendfiles.apk
			if [ "$?" -eq 0 ]; then
				echo "Send Files instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar Stremio
install_stremio(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.stremio.one)" != "" ]; then
		echo "Stremio já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o Stremio
		echo "Baixando Stremio..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/Ej3B9n4GajL5xPw/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o Stremio, aguarde..."
			adb install -r stremio.apk
			if [ "$?" -eq 0 ]; then
				echo "Stremio instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# Instalar X-Plore
install_xplore(){
	if [ "$(adb shell pm list packages -e | cut -f2 -d: | grep com.lonelycatgames.Xplore)" != "" ]; then
		echo "X-Plore já está instalado."
		pause "Tecle [Enter] para retornar ao menu Instalar Novos Apps" ; menu_install_apps
	else
		# Baixa o X-Plore
		echo "Baixando X-Plore..." && sleep 1
		wget --content-disposition https://cloud.talesam.org/s/LQXxP96zFj2QscL/download && clear
		if [ "$?" -ne 0 ]; then
			echo "Erro ao baixar o arquivo. Verifique sua conexão ou tente mais tarde."
		else
			echo "Instalando o X-Plore, aguarde..."
			adb install -r xplore.apk
			if [ "$?" -eq 0 ]; then
				echo "X-Plore instalado com sucesso!"
			else
				echo "Erro na instalação."
			fi
		fi
	fi
}

# --- INSTALAR NOVOS APPS - FIM

# --- MENU ---
# Menu principal
menu_principal(){
	clear
	option=0
	until [ "$option" = "5" ]; do
		echo ""
		echo -e " ${CYA}OTMIZAÇÃO TV TCL P8M, S6500 e S5300${STD} - ${YEL}$VER${STD}"

		# Verifica o Status da TV, se está conectada ou não via ADB
		ping -c 1 $IP >/dev/null 2>&1
		if [ "$?" -ne 0 ]; then
			echo -e " ${NEG}Status:${STD} ${RED}Desconectado${STD} ${NEG}via adb${STD}"
		else
			if [ "$(adb connect $IP | cut -f1 -d" " | grep -e connected -e already)" != "" ]; then
				echo -e " ${NEG}Status:${STD} ${GRE}Conectado${STD} ${NEG}via adb${STD}"
			else
				echo -e " ${NEG}Status:${STD} ${RED}Desconectado${STD} ${NEG}via adb.${STD}"
			fi
		fi
		echo ""
		echo -e " ${MAR136}Este script possui a finalidade de otimizar${STD}"
		echo -e " ${MAR136}o sistema Android TV, removendo e desativando${STD}"
		echo -e " ${MAR136}alguns apps e instalando outros.${STD}"
		echo ""
		echo -e " ${CUI}FAÇA POR SUA CONTA E RISCO${STD}"
		echo ""
		echo -e " ${BLU}1.$STD ${RED001}Remover apps lixo (P8M)${STD}"
		echo -e " ${BLU}2.$STD ${RED001}Remover apps lixo (S6500)${STD}"
		echo -e " ${BLU}3.$STD ${GRY247}Desativar${STD}/${GRE046}Ativar apps${STD}"
		echo -e " ${BLU}4.$STD ${ROX027}Launcher ATV Pro TCL Mod + Widget${STD}"
		echo -e " ${BLU}5.$STD ${GRE046}Instalar novos apps${STD}"
		echo -e " ${BLU}6.$STD ${RED}Sair${STD}"
		echo ""
		read -p " Digite um número e tecle [Enter]:" option
		case "$option" in
			1 ) rm_apps_p8m ;;
			2 ) rm_apps_S6500 ;;
			3 ) menu_ativar_desativar ;;
			4 ) menu_laucher ;;
			5 ) menu_install_apps ;;
			6 ) exit ; adb disconnect $IP >/dev/null ;;
			* ) clear; echo "Por favor escolha 1, 2, 3, 4, 5 ou 6"; 
		esac
	done
}

# Menu ativar/desativar apps
menu_ativar_desativar(){ 
	clear
	option=0
	until [ "$option" = "3" ]; do
		separacao
		echo -e " ${ROX027}Ativar e Desativar Apps${STD}"
		separacao
		echo ""
		echo -e " ${BLU}1.${STD} ${GRY247}Desativar apps${STD}"
		echo -e " ${BLU}2.${STD} ${GRE046}Ativar apps${STD}"
		echo -e " ${BLU}3.${STD} ${ROX063}Retornar ao Menu Principal${STD}"
		echo ""
		read -p " Digite um número:" option
		case $option in
			1 ) desativar ;;
			2 ) ativar ;;
			3 ) menu_principal ;;
			* ) clear; echo "Por favor, escolha 1, 2 ou 3";
		esac
	done
}

# Menu Instalar e ativar/desativar Laucher ATV PRO MOD
menu_laucher(){ 
	clear
	option=0
	until [ "$option" = "3" ]; do
		separacao
		echo -e " ${ROX027}Instalar e Ativar Laucher ATV PRO MOD${STD}"
		separacao
		echo ""
		echo -e " ${BLU}1.${STD} ${GRE046}Instalar e ativar Launcher${STD}"
		echo -e " ${BLU}2.${STD} ${GRY247}Desativar Laucher${STD}"
		echo -e " ${BLU}3.${STD} ${ROX063}Retornar ao Menu Principal${STD}"
		echo ""
		read -p " Digite um número:" option
		case $option in
			1 ) install_laucher ;;
			2 ) desativar_laucher ;;
			3 ) menu_principal ;;
			* ) clear; echo "Por favor, escolha 1, 2 ou 3";
		esac
	done
}

# Menu instalar novos apps
menu_install_apps(){ 
	clear
	option=0
	until [ "$option" = "9" ]; do
		separacao
		echo -e " ${ROX027}Instalar Novos Apps${STD}"
		separacao
		echo ""
		echo -e " ${BLU}1.${STD} Aptoide TV"
		echo -e " ${BLU}2.${STD} Deezer MOD"
		echo -e " ${BLU}3.${STD} Spotify MOD"
		echo -e " ${BLU}4.${STD} TV Bro"
		echo -e " ${BLU}5.${STD} Smart Youtube"
		echo -e " ${BLU}6.${STD} Send Files"
		echo -e " ${BLU}7.${STD} Stremio"
		echo -e " ${BLU}8.${STD} X-Plore"
		echo -e " ${BLU}9.${STD} ${ROX063}Retornar ao Menu Principal${STD}"
		echo ""
		read -p " Digite um número:" option
		case $option in
			1 ) install_aptoidetv ;;
			2 ) install_deezermod ;;
			3 ) install_spotify ;;
			4 ) install_tvbro ;;
			5 ) install_smartyoutube ;;
			6 ) install_sendfiles ;;
			7 ) install_stremio ;;
			8 ) install_xplore ;;
			9 ) menu_principal ;;
			* ) clear; echo "Por favor, escolha 1, 2, 3, 4, 5, 6, 7, 8 ou 9";
		esac
	done
}

# Cria um diretório temporário e joga todos arquivos lá dentro e remove ao sair
rm -rf .tmp
mkdir .tmp
cd .tmp
# Chama o script inicial
termux