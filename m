From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: Where Linux 802.11x support needs work
Date: Thu, 27 Jan 2005 19:09:24 +0100
Message-ID: <41F92E54.7020908@web.de>
References: <20050126024039.GA25326@bougret.hpl.hp.com> <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com> <200501252341.27041.flamingice@sourmilk.net> <41F74757.3090104@tihlde.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41F74757.3090104@tihlde.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Roar Bj=F8rgum Rotvik wrote:
> Is there an existing solution for this problem, or is an=20
> multiqueue-pr-device solution being planned as part of introducing a=20
> common 802.11 stack in the kernel?

Some (most or all?) Atheros chipsets have several priority queues. As=20
far as I can tell Madwifi is prepared for supporting them, as well as=20
the underlying 802.11 stack that has been ported from BSD. But I may be=20
wrong, as I'm by no means a madwifi-wizard :)

Bye, Mike
