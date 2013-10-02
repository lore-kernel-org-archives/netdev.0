From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tc: export tc_defact.h to userspace
Date: Wed, 02 Oct 2013 16:39:30 -0400 (EDT)
Message-ID: <20131002.163930.1614877848852017513.davem@davemloft.net>
References: <20130930213022.073850bb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab3JBUjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:39:32 -0400
In-Reply-To: <20130930213022.073850bb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Sep 2013 21:30:22 -0700

> Jamal sent patch to add tc user simple actions to iproute2
> but required header was not being exported.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
