From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Bug report: RT2800USB driver. txpower stuck at 0
Date: Sun, 03 Jun 2012 09:09:05 +0200
Message-ID: <4FCB0D91.7070504@computer.org>
References: <CAOUAToY-uDxGLk475RvMY2uu9GwQ4dnPfFx0aCz4eO25L=6nDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vilius Palme <palme3000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:15065 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879Ab2FCHJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2012 03:09:58 -0400
In-Reply-To: <CAOUAToY-uDxGLk475RvMY2uu9GwQ4dnPfFx0aCz4eO25L=6nDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2012 11:59 PM, Vilius Palme wrote:
> Hello.
> 
> Is this the place to report net driver bugs?
> 
> Just tried to make a switch from 3.3.5 to 3.4.0 kernel and it seems
> that something is wrong with RT2800USB driver. iwlwifi driver seems to
> work pretty fine, so I assume that this is RT driver problem.

janc@mordor:~/git/net-next$ ./scripts/get_maintainer.pl -f
drivers/net/wireless/rt2x00/rt2800usb.c
Ivo van Doorn <IvDoorn@gmail.com> (maintainer:RALINK RT2X00 WIR...)
Gertjan van Wingerde <gwingerde@gmail.com> (maintainer:RALINK RT2X00 WIR...)
Helmut Schaa <helmut.schaa@googlemail.com> (maintainer:RALINK RT2X00 WIR...)
"John W. Linville" <linville@tuxdriver.com> (maintainer:NETWORKING
[WIREL...)
linux-wireless@vger.kernel.org (open list:RALINK RT2X00 WIR...)
users@rt2x00.serialmonkey.com (moderated list:RALINK RT2X00 WIR...)
netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
linux-kernel@vger.kernel.org (open list)

So you've not come to the wrong place exactly, but the linux-wireless
mailing list (being more specialised than netdev) is a forum in which
you are more likely to get someone to look at your issue.

HTH, Jan
