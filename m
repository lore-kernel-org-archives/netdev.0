From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ax88796: free irq on error
Date: Thu, 08 Jul 2010 23:42:51 -0700 (PDT)
Message-ID: <20100708.234251.233681044.davem@davemloft.net>
References: <1278590996-3122-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, p_gortmaker@yahoo.com,
	julia@diku.dk, tj@kernel.org, joe@perches.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544Ab0GIGmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:42:37 -0400
In-Reply-To: <1278590996-3122-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Thu,  8 Jul 2010 16:09:54 +0400

> If ax_ei_open() failed we must free previously requested irq.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
