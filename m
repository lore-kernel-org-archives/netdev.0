From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 05:17:22 -0800 (PST)
Message-ID: <20091116.051722.255835290.davem@davemloft.net>
References: <20091116.024839.257258321.davem@davemloft.net>
	<20091116.025859.78494103.davem@davemloft.net>
	<412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41903
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651AbZKPNRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:17:06 -0500
In-Reply-To: <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 16 Nov 2009 21:05:28 +0800

> I am sorry about that. But I did test it before submitting these two,
> and I am just wondering if they are applied without any error. Would
> you post the file after being patched? I think it will be helpful to
> finger out the real problem.

I don't have time for that sorry.

I think the problem might be that you are developing against
either net-2.6 or Linus's tree, whereas you should be working
against net-next-2.6
