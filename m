From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 22:28:07 +0100
Message-ID: <1296077287.2631.9.camel@edumazet-laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
	 <1296073390.2631.4.camel@edumazet-laptop>
	 <1296077098.2448.5.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33131 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab1AZV2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 16:28:11 -0500
Received: by wwa36 with SMTP id 36so1460651wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 13:28:10 -0800 (PST)
In-Reply-To: <1296077098.2448.5.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 13:24 -0800, Joe Perches a =C3=A9cri=
t :

> Ugly maybe, but correct, definitely.
> The same can not be said of the {0}.

What about fixing real problems Joe ?

Are you telling me I dont know C ?



