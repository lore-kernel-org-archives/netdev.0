From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neterion: remove reference to ifconfig
Date: Sun, 08 Mar 2015 19:12:05 -0400 (EDT)
Message-ID: <20150308.191205.942822413315313829.davem@davemloft.net>
References: <20150308114849.6423e5b7@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbbCHXMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 19:12:09 -0400
In-Reply-To: <20150308114849.6423e5b7@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 8 Mar 2015 11:48:49 -0700

> Remove reference to obsolete ifconfig command.
> MTU can be changed with ip command instead.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
