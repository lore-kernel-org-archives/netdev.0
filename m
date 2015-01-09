From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 20150108
Date: Thu, 08 Jan 2015 20:14:55 -0800 (PST)
Message-ID: <20150108.201455.1089469097589757110.davem@davemloft.net>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbbAIEJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 23:09:11 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Thu,  8 Jan 2015 16:15:05 +0100

> this is a batch of patches intended for net-next.
> 
> In this patchset you have mostly cleanups and small corrections to issues
> reported by checkpatch.
> 
> One notable change is the addition of the DEBUG_FS dependency to the
> BATMAN_ADV_DEBUG symbol by Markus Pargmann. We add this dependency because all
> the information provided by the DEBUG feature is accessible only through
> debugfs.

Pulled, thanks Antonio.
