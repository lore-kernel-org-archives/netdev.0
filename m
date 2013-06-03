From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Sun, 02 Jun 2013 20:47:42 -0700
Message-ID: <1370231262.24311.122.camel@edumazet-glaptop>
References: <1370215895.24311.93.camel@edumazet-glaptop>
	 <20130602.195826.721294433730539253.davem@davemloft.net>
	 <1370229169.24311.119.camel@edumazet-glaptop>
	 <20130602.202703.1059637861388689182.davem@davemloft.net>
	 <20130603034254.GC29614@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, klamm@yandex-team.ru,
	brouer@redhat.com, dipankar@in.ibm.com, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, David.Laight@ACULAB.COM
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54502 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab3FCDrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 23:47:45 -0400
In-Reply-To: <20130603034254.GC29614@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 20:42 -0700, Paul E. McKenney wrote:

> Or if you would like to take it:
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 

Thanks guys !
