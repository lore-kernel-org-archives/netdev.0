From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6 route: use err pointers instead of
 returning pointer by reference
Date: Mon, 12 Oct 2015 19:47:57 -0700 (PDT)
Message-ID: <20151012.194757.872102916771102248.davem@davemloft.net>
References: <1444490796-47173-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194AbbJMCb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:31:57 -0400
In-Reply-To: <1444490796-47173-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sat, 10 Oct 2015 08:26:36 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch makes ip6_route_info_create return err pointer instead of
> returning the rt pointer by reference as suggested  by Dave
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v1 - v2: remove unnecessary NULL initialization of rt as pointed out by scott feldman

Applied, thanks.
