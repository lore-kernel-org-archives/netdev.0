From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 05:33:29 -0800 (PST)
Message-ID: <20091116.053329.215126585.davem@davemloft.net>
References: <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
	<20091116.051722.255835290.davem@davemloft.net>
	<412e6f7f0911160522w34895b0eked14f69ccc62c96b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbZKPNdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:33:13 -0500
In-Reply-To: <412e6f7f0911160522w34895b0eked14f69ccc62c96b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 16 Nov 2009 21:22:46 +0800

> I am working against linux-next. I'll check if there is any
> difference. BTW: were these patches applied in order, 1 - 2?

Yes, they were.
