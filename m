From: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 16:34:44 +0200
Message-ID: <577FBA04.8000706@gmx.de>
References: <577FAFFD.2020306@gmx.de>
 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54067 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254AbcGHOet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 10:34:49 -0400
In-Reply-To: <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 04:14 PM, Eric Dumazet wrote:
> Are you sure conntrack is needed at all ?

Erm, I didn't mention conntrack - but yes, I do have in the firewall rules.

It is my understanding that conntrack is best practise, right ?

-- 
Toralf
PGP: C4EACDDE 0076E94E, OTR: 420E74C8 30246EE7
