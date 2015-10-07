From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump
 by device index
Date: Wed, 07 Oct 2015 04:12:48 -0700 (PDT)
Message-ID: <20151007.041248.1713214945229649462.davem@davemloft.net>
References: <1443897826-30209-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbJGK5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:57:07 -0400
In-Reply-To: <1443897826-30209-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat,  3 Oct 2015 11:43:46 -0700

> Add support for filtering neighbor dumps by device by adding the
> NDA_IFINDEX attribute to the dump request.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - fix or on the index as noticed by Eagle-Eye Nikolay

Applied, thanks.
