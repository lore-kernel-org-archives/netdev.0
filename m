From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 18:57:08 -0700 (PDT)
Message-ID: <20090617.185708.41706567.davem@davemloft.net>
References: <20090615111927.GA12316@ff.dom.local>
	<1245072728.3948.14.camel@dogo.mojatatu.com>
	<20090616183355.GA3800@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, pstaszewski@itcare.pl, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757019AbZFRB5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:57:04 -0400
In-Reply-To: <20090616183355.GA3800@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 16 Jun 2009 20:33:55 +0200

> pkt_sched: Update drops stats in act_police
> 
> Action police statistics could be misleading because drops are not
> shown when expected.
> 
> With feedback from: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks!
