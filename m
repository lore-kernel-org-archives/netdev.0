From: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 18:10:46 +0200
Message-ID: <577FD086.2000208@gmx.de>
References: <577FAFFD.2020306@gmx.de>
 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
 <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:53806 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164AbcGHQK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 12:10:58 -0400
In-Reply-To: <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 05:38 PM, Eric Dumazet wrote:
> With IPv4, a server can typically absorb 10 Mpps SYN without major
> disruption on linux-4.6
Well, this particular server even survived >900 MBit/sec w/o any service disruption at IPv4 ([1])
but yesterday with a much more less attack the IPv6 issue was bothering me.

[1] https://www.zwiebeltoralf.de/torserver/ddos_sysstat_example.txt

-- 
Toralf
PGP: C4EACDDE 0076E94E, OTR: 420E74C8 30246EE7
