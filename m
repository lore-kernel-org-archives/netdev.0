From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Thu, 04 Dec 2014 17:40:24 +0100
Message-ID: <54808E78.6070603@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <54802D14.9030509@suse.cz>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jiri Slaby <jslaby@suse.cz>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54802D14.9030509@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Am 04.12.2014 10:44, schrieb Jiri Slaby:
> On 12/03/2014, 03:55 PM, Smart Weblications GmbH - Florian Wiessner w=
rote:

>> [16623.095403] BUG: unable to handle kernel paging request at 000000=
00010600d0
[...]
>> [16623.096721] Call Trace:
[...]

>> This happens again and again with 3.12.33
>>
>>
>> see also: http://www.spinics.net/lists/netdev/msg306283.html
>>
>> is this already fixed somehow?
>=20
> Hi, I doubt so, as you are the first one letting me know. Could you
> check whether 3.12.30 works OK for you?
>=20

I can try that, but it will take me some time as i currently try a kern=
el
without xfrm support to calm down my users.

Could you please look at my other mail first, before i downgrade the ke=
rnel?


--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
