From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ethernet: cleanup eth_type_trans
Date: Mon, 30 Sep 2013 21:53:37 -0700 (PDT)
Message-ID: <20130930.215337.900497241404899825.davem@davemloft.net>
References: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3JAEqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:46:35 -0400
In-Reply-To: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 27 Sep 2013 17:19:41 -0700

> Remove old legacy comment and weird if condition.
> The comment has outlived it's stay and is throwback to some
> early net code (before my time). Maybe Dave remembers what it meant.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
