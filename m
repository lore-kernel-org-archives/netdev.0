From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support
 Nokia Slim Modems
Date: Mon, 27 Sep 2010 21:50:59 -0700 (PDT)
Message-ID: <20100927.215059.39193491.davem@davemloft.net>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	STEricsson_nomadik_linux@list.st.com,
	sudeep.divakaran@stericsson.com, gulshan.karmani@stericsson.com,
	linus.walleij@stericsson.com
To: kumar.sanghvi@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041Ab0I1Euj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:50:39 -0400
In-Reply-To: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Date: Mon, 27 Sep 2010 10:37:59 +0530

> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> 
> Phonet stack assumes the presence of Pipe Controller, either in Modem or
> on Application Processing Engine user-space for the Pipe data.
> Nokia Slim Modems like WG2.5 used in ST-Ericsson U8500 platform do not
> implement Pipe controller in them.
> This patch adds Pipe Controller implemenation to Phonet stack to support
> Pipe data over Phonet stack for Nokia Slim Modems.
> 
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>

Applied, thanks.

Please resubmit patch 2/2 if you want me to apply it.
