From: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 17:03:51 +0200
Message-ID: <577FC0D7.4000902@gmx.de>
References: <577FAFFD.2020306@gmx.de>
 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:60920 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847AbcGHPEC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 11:04:02 -0400
In-Reply-To: <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 04:14 PM, Eric Dumazet wrote:
> Hard to tell without knowing DDOS details, but IPv6 lacks some
> scalability improvements found in IPv4.

Well, not too much I got from my ISP :

On 07 Jul 15:42, flow-save@traffic1.core.hetzner.de wrote:
> Direction IN
> Internal 5.9.158.75
> Threshold Packets 300.000 packets/s
> Sum 100.982.000 packets/300s (336.606 packets/s), 100.769 flows/300s (335 flows/s), 6,093 GByte/300s (166 MBit/s)
> External 84.1.57.68, 824.000 packets/300s (2.746 packets/s), 823 flows/300s (2 flows/s), 0,046 GByte/300s (1 MBit/s)
> External 78.189.187.159, 748.000 packets/300s (2.493 packets/s), 748 flows/300s (2 flows/s), 0,042 GByte/300s (1 MBit/s)
> External 85.105.165.143, 725.000 packets/300s (2.416 packets/s), 725 flows/300s (2 flows/s), 0,041 GByte/300s (1 MBit/s)
> External 88.250.158.160, 715.000 packets/300s (2.383 packets/s), 715 flows/300s (2 flows/s), 0,040 GByte/300s (1 MBit/s)
> External 88.248.51.37, 714.000 packets/300s (2.380 packets/s), 714 flows/300s (2 flows/s), 0,040 GByte/300s (1 MBit/s)
> External 78.186.151.2, 708.000 packets/300s (2.360 packets/s), 708 flows/300s (2 flows/s), 0,040 GByte/300s (1 MBit/s)


-- 
Toralf
PGP: C4EACDDE 0076E94E, OTR: 420E74C8 30246EE7
