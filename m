From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6]: Treat ND option 31 as userland (DNSSL support)
Date: Thu, 12 Apr 2012 15:57:51 -0400 (EDT)
Message-ID: <20120412.155751.1199132283692746721.davem@davemloft.net>
References: <1333727458-28438-1-git-send-email-raorn@raorn.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raorn@raorn.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab2DLT64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 15:58:56 -0400
In-Reply-To: <1333727458-28438-1-git-send-email-raorn@raorn.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexey I. Froloff" <raorn@raorn.name>
Date: Fri,  6 Apr 2012 19:50:58 +0400

> As specified in RFC6106, DNSSL option contains one or more domain names
> of DNS suffixes.  8-bit identifier of the DNSSL option type as assigned
> by the IANA is 31.  This option should also be treated as userland.
> 
> Signed-off-by: Alexey I. Froloff <raorn@raorn.name>

Applied to net-next, thanks.
