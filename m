From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] net: ethernet: renesas: ravb_main: don't open code
 of_device_get_match_data()
Date: Wed, 2 Mar 2016 10:19:30 +0900
Message-ID: <20160302011930.GA32543@verge.net.au>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53211 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbcCBBTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 20:19:34 -0500
Content-Disposition: inline
In-Reply-To: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 05:37:58PM +0100, Wolfram Sang wrote:
> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> 
> This change will also make Coverity happy by avoiding a theoretical NULL
> pointer dereference; yet another reason is to use the above helper function
> to tighten the code and make it more readable.
> 
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
