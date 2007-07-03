From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen IPSEC 2/4: Introduce pktgen sequential flows
Date: Mon, 02 Jul 2007 22:40:46 -0700 (PDT)
Message-ID: <20070702.224046.91211971.davem@davemloft.net>
References: <1181649373.4060.50.camel@localhost>
	<1181649628.4060.54.camel@localhost>
	<1181649715.4060.56.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, jmorris@namei.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbXGCFk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:40:26 -0400
In-Reply-To: <1181649715.4060.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 12 Jun 2007 08:01:55 -0400

> commit 882c296bb3f153e1ac770a874c75cfb2bab8481b
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Tue Jun 12 07:24:00 2007 -0400
> 
>     [PKTGEN] Introduce sequential flows
>     
>     By default all flows in pktgen are randomly selected.
>     This patch introduces ability to have all defined flows to
>     be sent sequentially. Robert defined randomness to be the
>     default behavior.
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied.
