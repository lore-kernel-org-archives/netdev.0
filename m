From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 0/3 net-next] xen-netfront: refactor making Tx
 requests
Date: Wed, 14 Jan 2015 00:23:01 -0500 (EST)
Message-ID: <20150114.002301.980993906256605452.davem@davemloft.net>
References: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbANFXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 00:23:03 -0500
In-Reply-To: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 13 Jan 2015 17:16:41 +0000

> As netfront as evolved to handle different sorts of skbs the code to
> fill a Tx requests has been copy and pasted several times.  The series
> refactors this and a few other areas.
> 
> The first patch is to a Xen header but this can be merged via
> net-next.

Series applied, thanks David.
