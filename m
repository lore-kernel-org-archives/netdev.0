From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Thu, 23 Apr 2009 19:32:49 +0200
Message-ID: <49F0A641.90303@cosmosbay.com>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org> <49F09933.2010200@cosmosbay.com> <20090423165620.GB30405@hmsreliant.think-freely.org> <49F0A1C8.5080601@cosmosbay.com> <20090423172524.GC30405@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43544 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbZDWRc7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 13:32:59 -0400
In-Reply-To: <20090423172524.GC30405@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :

> Perhaps we could define the size of each counter at compile time, so =
that at
> least 64 bit systems can have sane counters?

Well, mibs are "unsigned long", so are 64 bits on these systems.

>=20
> Btw, I will repost one more time to take in the above enhancement you=
 suggested
> regarding the limited use of per_cpu_ptr and in_softirq (my last post=
 made it
> sound like I wouldnt)

OK, thanks

