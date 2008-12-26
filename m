From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] qlge: bugfix: Fix register access error checking.
Date: Fri, 26 Dec 2008 01:20:07 -0800 (PST)
Message-ID: <20081226.012007.164611402.davem@davemloft.net>
References: <1229990258-14507-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752886AbYLZJUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:20:04 -0500
In-Reply-To: <1229990258-14507-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 22 Dec 2008 15:57:33 -0800

> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> old mode 100644
> new mode 100755

Please resubmit this patch set without these file mode changes.
