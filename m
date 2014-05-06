From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/24] net, diet: Make TCP fastopen optional
Date: Mon, 05 May 2014 23:06:44 -0400 (EDT)
Message-ID: <20140505.230644.165862049328890181.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-17-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731AbaEFDGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:06:45 -0400
In-Reply-To: <1399328773-6531-17-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:05 -0700

> Make TCP fast open a config option. It's not really needed
> on small systems. By itself it saves about 3k text,

It's for the sake of the remote service not the local client,
sorry I'm not applying this, it's a facility we want to be
ubiquitous and in widespread use on as many systems as possible.

I'm not applying this, sorry.
