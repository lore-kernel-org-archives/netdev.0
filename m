From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/24] net, diet: Make ethtool optional
Date: Mon, 05 May 2014 23:11:40 -0400 (EDT)
Message-ID: <20140505.231140.2172378266544060318.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-10-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933818AbaEFDLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:11:42 -0400
In-Reply-To: <1399328773-6531-10-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:58 -0700

> Small embedded systems don't need ethtool, so make it optional.

You can't do anything non-trivial with an ethernet device without
ethtool.

I am not applying this.
