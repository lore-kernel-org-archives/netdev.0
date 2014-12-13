From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Sat, 13 Dec 2014 07:05:30 +0100
Message-ID: <548BD72A.6040809@users.sourceforge.net>
References: <548B0A29.8050503@users.sourceforge.net>	 <20141212.105106.1162681032492664308.davem@davemloft.net>	 <548B1E44.6050005@users.sourceforge.net>	 <20141212.115922.687789059853236747.davem@davemloft.net>	 <548B2468.5050402@users.sourceforge.net> <1418411287.13491.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:58441 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965236AbaLMGF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Dec 2014 01:05:58 -0500
In-Reply-To: <1418411287.13491.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We are in the merge window, tracking bugs added in latest dev cycle.

I am also curious on the software evolution about how many improvements will
arrive in the next Linux versions.


> Having to deal with patches like yours is adding pressure
> on the maintainer (and other developers) at the wrong time.

You can relax a bit eventually. More merge windows will follow, won't they?

It will be nice if a bunch of recent code clean-ups which were also
triggered
by static source code analysis will be integrated into Linux 3.19 already.
More update suggestions will be considered later again as usual.

Regards,
Markus
