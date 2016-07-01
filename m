From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qede: Enhancements
Date: Fri, 01 Jul 2016 05:43:05 -0400 (EDT)
Message-ID: <20160701.054305.2286397431645050772.davem@davemloft.net>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbcGAJoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:44:18 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 30 Jun 2016 02:35:17 -0400

> This patch series have few small fastpath features
> support and code refactoring.
> 
> Note - regarding get/set tunable configuration via ethtool
> Surprisingly, there is NO ethtool application support for
> such configuration given that we have kernel support.
> Do let us know if we need to add support for that in user ethtool.
> 
> Please consider applying this series to "net-next".

Series applied, thanks.
