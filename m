From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] nfp: few code improvements
Date: Thu, 30 Jun 2016 09:30:39 -0400 (EDT)
Message-ID: <20160630.093039.1888873867696709102.davem@davemloft.net>
References: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbcF3NbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:31:20 -0400
In-Reply-To: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 29 Jun 2016 21:55:52 +0100

> Three small patches for net-next.  First and second patches
> improve the code quality by spelling things correctly and
> removing unused parameters.  Third patch hooks-in standard
> kernel implementation of .get_link() in ethtool ops.

Series applied, thanks.
