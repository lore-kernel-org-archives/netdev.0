From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 2/2] qlcnic: add external loopback support
Date: Thu, 30 Jun 2011 23:58:59 -0700 (PDT)
Message-ID: <20110630.235859.937003839356164375.davem@davemloft.net>
References: <1309413650-15952-1-git-send-email-amit.salecha@qlogic.com>
	<1309413650-15952-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, sucheta.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab1GAG7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:59:01 -0400
In-Reply-To: <1309413650-15952-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Wed, 29 Jun 2011 23:00:50 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> o Add external loopback test in self test:
>   - Send set external loopback mode request to fw.
>      To quiscent other storage functions.
>   - Perform test
>   - Send unset loopback mode request to fw.
> 
> o Rename ilb to lb.
> o Update driver version 5.0.20.
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
