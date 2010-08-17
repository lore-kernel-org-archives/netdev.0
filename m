From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: fix all checkpatch errors and warnings
Date: Tue, 17 Aug 2010 02:34:56 -0700 (PDT)
Message-ID: <20100817.023456.104039303.davem@davemloft.net>
References: <201008082208.46396.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160Ab0HQJei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:38 -0400
In-Reply-To: <201008082208.46396.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 8 Aug 2010 22:08:44 +0200

> This patch fixes a couple of errors and warnings spotted by checkpatch.pl:
> - some lines were over 80 columns
> - there were some whitespaces left
> 
> The call to printk is now replaced by a call to pr_info and the log-level
> included in the driver version is now removed, so there are no longer false
> positives on this warning.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
