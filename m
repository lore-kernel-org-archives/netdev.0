From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sh_eth: massage PM code
Date: Mon, 26 Jan 2015 15:27:15 -0800 (PST)
Message-ID: <20150126.152715.1448055643815693106.davem@davemloft.net>
References: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410AbbA0AoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:44:02 -0500
In-Reply-To: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 22 Jan 2015 01:16:54 +0300

>    Here's a set of 2 patches against DaveM's 'net-next.git' repo. We're adding
> the support for suspend/hibernation as well as somewhat changing the existing
> code. There are still MDIO-related issue with suspend (kernel exception), we've
> been working on it and shall address it with a separate patch...

Series applied, thanks.
