From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: validate peer name and attribute lengths
Date: Sun, 27 Mar 2011 17:59:43 -0700 (PDT)
Message-ID: <20110327.175943.112617524.davem@davemloft.net>
References: <1300671126.9043.8.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753023Ab1C1BAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:00:21 -0400
In-Reply-To: <1300671126.9043.8.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Sun, 20 Mar 2011 21:32:06 -0400

> Length fields provided by a peer for names and attributes may be longer
> than the destination array sizes.  Validate lengths to prevent stack
> buffer overflows.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable@kernel.org

Applied.
