From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gigaset: use pr_err() and pr_info()
Date: Fri, 26 Dec 2008 01:21:39 -0800 (PST)
Message-ID: <20081226.012139.229871700.davem@davemloft.net>
References: <20081223-patch-00.tilman@imap.cc>
	<200812230927.mBN9RG9k028586@mail.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752966AbYLZJVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:21:36 -0500
In-Reply-To: <200812230927.mBN9RG9k028586@mail.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 23 Dec 2008 10:27:16 +0100

> Switch from private printk wrapper macros to using pr_err() and
> pr_info() from linux/kernel.h, at the same time unifying a few
> error messages.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
