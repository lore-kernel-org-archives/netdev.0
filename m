From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix warnings in 'make htmldocs' by moving
 macro definition out of field declaration
Date: Wed, 16 Dec 2015 11:44:29 -0500 (EST)
Message-ID: <20151216.114429.1645588574130410657.davem@davemloft.net>
References: <1450132243-12741-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965686AbbLPQob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:44:31 -0500
In-Reply-To: <1450132243-12741-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 14 Dec 2015 23:30:43 +0100

> Docbook does not like the definition of macros inside a field declaration
> and adds a warning. Move the definition out.
> 
> Fixes: 79462ad02e86180 ("net: add validation for the socket syscall protocol argument")
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks!
