From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: add missing import <linux/export.h>
Date: Sun, 07 Jun 2015 00:10:31 -0700 (PDT)
Message-ID: <20150607.001031.1532896029440550000.davem@davemloft.net>
References: <1433621243-30976-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbFGHKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 03:10:32 -0400
In-Reply-To: <1433621243-30976-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat,  6 Jun 2015 22:07:23 +0200

> rhashtable uses EXPORT_SYMBOL_GPL() without importing linux/export.h
> directly it is only imported indirectly through some other includes.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied, thanks.
