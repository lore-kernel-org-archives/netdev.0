From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] qlcnic: fix ethtool diagnostics test
Date: Mon, 10 Jan 2011 13:35:09 -0800 (PST)
Message-ID: <20110110.133509.216756441.davem@davemloft.net>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
	<1294654523-3085-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, sony.chacko@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1AJVeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:34:37 -0500
In-Reply-To: <1294654523-3085-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 10 Jan 2011 02:15:22 -0800

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> IRQ diag test was getting executed only when both register test
> and link test passed. The test should get executed if ETH_TEST_FL_OFFLINE
> flag is set.
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
