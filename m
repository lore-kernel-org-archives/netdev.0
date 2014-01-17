From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net]: batman-adv 2014-01-16
Date: Thu, 16 Jan 2014 17:17:11 -0800 (PST)
Message-ID: <20140116.171711.1684801994017990455.davem@davemloft.net>
References: <1389827444-3911-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaAQBRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:17:12 -0500
In-Reply-To: <1389827444-3911-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Thu, 16 Jan 2014 00:10:43 +0100

> here you have a very small fix intended for net/linux-3.13.
> 
> This patch is fixing the batman-adv overhead computation
> (by Marek Lindner).
> The result of such operation is used to initialize the
> hard_header_len member of the soft-interface netdev object.
> 
> Please pull or let me know of any problem!

Pulled, thanks Antonio.
