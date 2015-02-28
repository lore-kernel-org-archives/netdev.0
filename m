From: Andre Valentin <avalentin@marcant.net>
Subject: Re: Kernel Panic with vti Interfaces
Date: Sat, 28 Feb 2015 22:21:53 +0100
Message-ID: <54F23171.9010901@marcant.net>
References: <54EC4C63.3050006@marcant.net> <20150226114052.GB20631@secunet.com> <54EFB312.8040309@marcant.net> <20150227103506.GD20631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.marcant.net ([217.14.160.186]:42690 "EHLO
	mail2.marcant.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbB1VWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 16:22:01 -0500
In-Reply-To: <20150227103506.GD20631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Am 27.02.2015 um 11:35 schrieb Steffen Klassert:
> On Fri, Feb 27, 2015 at 12:58:10AM +0100, Andre Valentin wrote:
>>
>>>
>>> I have never seen this, is the patch above the only locally
>>> applied patch?
>> No, the kernel is coming from the current openwrt 3.18 trunk.
>> It's 3.18.7 with serveral patches coming from openwrt.
>> I already checked the IPsec related patches but the error
>> persisted.
>>
>> I will remove more patches to be sure and forward my results!
>
> Please try with an unpatched kernel from kernel.org, thanks!
>

I just retried with vanilla on x86_64 and there no such error.
I'm sorry for the noise. I've been sure that I could exclude
the openwrt patches.  Thank you very much for your help.

Kind regards,

Andr=E9


Mit freundlichen Gr=FC=DFen
 Andr=E9 Valentin
Systemadministrator
--

++++++WIR ZIEHEN UM++++++
Ab dem 09.03.2015 erreichen Sie uns unter folgender Anschrift.

MarcanT GmbH
Herforder Stra=DFe 163 a
33609 Bielefeld

Bitte beachten Sie, dass ab dem 09.03.2015 alle Rechnungen und
Korrespondenz nur noch auf die oben genannte Anschrift ausgestellt
werden. Aktualisieren Sie bitte Ihre Stammdaten entsprechend. Wir
w=FCnschen uns, den Umzug f=FCr Sie und uns ohne Beeintr=E4chtigungen d=
es
Tagesgesch=E4ftes abwickeln zu k=F6nnen. Sollte es dennoch zu Schwierig=
keiten
kommen, hoffen wir auf Ihr Verst=E4ndnis.
Auf unser Rechenzentrum hat der Umzug keinen Einfluss; die Funktionen
wurden bereits Anfang Februar auf unsere Redundanzrechenzentren verteil=
t.
++++++++++++++++++++++++++++++++++++

MarcanT GmbH, Ravensberger Str. 10 G, D - 33602 Bielefeld
=46on: +49 (521) 95945-0 | Fax: +49 (521) 95945-18
URL: http://www.marcant.net | http://www.global-m2m.com

Internet * Netzwerk * Mobile Daten
Citrix Silver Solution Advisor

Gesch=E4ftsf=FChrer: Thorsten Hojas
Handelsregister: AG Bielefeld, HRB 35827 USt-ID Nr.: DE 190203238
___________________________________________________________
Ausserhalb unserer Gesch=E4ftszeiten (Montag bis Freitag von 8:30 Uhr b=
is
17:30 Uhr, ausgenommen gesetzliche Feiertage in NRW) stehen wir Ihnen
gem=E4=DF Ihrer jeweiligen Service-Level-Agreements unter der Ihnen
mitgeteilten Telefonnummer f=FCr St=F6rungen und Notf=E4lle zur Verf=FC=
gung.
Sie k=F6nnen nat=FCrlich auch gerne jederzeit unter support@marcant.net=
 ein
Ticket er=F6ffnen, welches am n=E4chsten Arbeitstag bearbeitet wird.
