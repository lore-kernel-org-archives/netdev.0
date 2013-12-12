From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 14:06:09 -0500 (EST)
Message-ID: <20131212.140609.955709321823979833.davem@davemloft.net>
References: <52A9F93A.5040104@gmail.com>
	<20131212.132441.1907656115241279246.davem@davemloft.net>
	<20131212190042.GH4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, dvlasenk@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131212190042.GH4675@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 12 Dec 2013 20:00:42 +0100

> IMHO both ways are fine with a slight opionion to counters being
> overkill. ;)

Counters don't scroll out of the log last time I checked too :)
