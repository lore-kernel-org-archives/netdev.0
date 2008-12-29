From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 1/6] qlge: bugfix: Fix register access error checking.
Date: Mon, 29 Dec 2008 14:49:18 -0800
Message-ID: <20081229224918.GC16018@susedev.qlogic.org>
References: <1229990258-14507-1-git-send-email-ron.mercer@qlogic.com> <20081226.012007.164611402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	Linux Driver <Linux-Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbYL2WtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 17:49:19 -0500
Content-Disposition: inline
In-Reply-To: <20081226.012007.164611402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 26, 2008 at 01:20:07AM -0800, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Mon, 22 Dec 2008 15:57:33 -0800
> 
> > diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> > old mode 100644
> > new mode 100755
> 
> Please resubmit this patch set without these file mode changes.

I will respin all the patches tomorrow as I am cleaning up one of them
due to some useful feedback.

