From: David Miller <davem@davemloft.net>
Subject: Re: what's causing "ip_rt_bug"?
Date: Tue, 28 Jun 2011 01:40:37 -0700 (PDT)
Message-ID: <20110628.014037.1182738430053461203.davem@davemloft.net>
References: <alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg>
	<20110627.205544.111681152997205782.davem@davemloft.net>
	<4E099113.6000801@wpkg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bazsi@balabit.hu, hidden@balabit.hu
To: mangoo@wpkg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756736Ab1F1Ik5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 04:40:57 -0400
In-Reply-To: <4E099113.6000801@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomasz Chmielewski <mangoo@wpkg.org>
Date: Tue, 28 Jun 2011 10:30:11 +0200

> Can you tell me where it will be pushed?
> 
> I.e. 3.x kernels only, or does it have a chance to go into 2.6.39.x?

I'll apply it for 3.0.0 and also queue it up for -stable.
