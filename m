From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] vlan: rcu annotations
Date: Mon, 25 Oct 2010 13:10:35 -0700 (PDT)
Message-ID: <20101025.131035.179950146.davem@davemloft.net>
References: <1287991918.2658.5379.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757675Ab0JYUKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:10:12 -0400
In-Reply-To: <1287991918.2658.5379.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 09:31:58 +0200

> (struct net_device)->vlgrp is rcu protected :
> 
> add __rcu annotation and proper rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
