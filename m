From: Matthieu CASTET <castet.matthieu@free.fr>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 23:07:54 +0100
Message-ID: <pan.2006.02.25.22.07.53.810642@free.fr>
References: <43FF88E6.6020603@linux.intel.com> <20060225084139.GB22109@infradead.org> <200602250549.47547.gene.heskett@verizon.net> <Pine.LNX.4.61.0602251518200.31692@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750963AbWBYWIU@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everybody,

Le Sat, 25 Feb 2006 15:19:40 +0100, Jan Engelhardt a =E9crit=A0:

>>If the modules crc changes,=20
>>it must do an instant disable of the transmitter functions and exit o=
r=20
>>crash, thereby precluding any 'hot rodding' of the chipset.
>>
> Would not it be easiest to have the chipset enforce the acceptable ba=
nds?=20
> So that software can't switch the chipset to 1337 GHz no matter how h=
ard=20
> you forward/reverse-engineer it.
>=20
I will say, why not put the restriction of the firmware binary blob ?
It run on the device so it will be difficult for people to analyse it.

Also the firmware could be on a eeprom and transparent for the user.


Matthieu
