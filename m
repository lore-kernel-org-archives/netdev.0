From: David Miller <davem@davemloft.net>
Subject: Re: Softirqs without captured packets
Date: Fri, 08 Feb 2013 15:15:23 -0500 (EST)
Message-ID: <20130208.151523.798634382725569230.davem@davemloft.net>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
	<20130208.145728.1110053781319882182.davem@davemloft.net>
	<CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: javierdo1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068Ab3BHUPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 15:15:25 -0500
In-Reply-To: <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Domingo <javierdo1@gmail.com>
Date: Fri, 8 Feb 2013 21:02:41 +0100

> Sorry, I think I misexplained,
> 
> I wanted to say net's receive softirq: net_rx_action, not softirqs in general.

If you don't show us your code we have to guess all sorts of things
like this.

Don't expect much help until you post your tracer module.
