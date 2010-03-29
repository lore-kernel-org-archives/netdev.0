From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 14:16:34 +0200
Message-ID: <1269864994.2164.21.camel@edumazet-laptop>
References: <4BB09021.6020202@petalogix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: michal.simek@petalogix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62781 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab0C2MQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:16:40 -0400
In-Reply-To: <4BB09021.6020202@petalogix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 13:33 +0200, Michal Simek a =C3=A9crit :

> Do you have any idea howto improve TCP/UDP performance in general?
> Or tests which can point me on weak places.

Could you post "netstat -s" on your receiver, after fresh boot and your
iperf session, for 32 MB and 256 MB ram case ?


