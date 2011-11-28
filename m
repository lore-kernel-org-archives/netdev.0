From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net-next 2/3] dsa: Move all definitions needed by drivers
 into <net/dsa.h>
Date: Mon, 28 Nov 2011 22:13:26 +0100
Message-ID: <20111128211326.GZ795@wantstofly.org>
References: <1322449506.7454.34.camel@deadeye>
 <1322449568.7454.35.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:63734 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab1K1VN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:13:28 -0500
Content-Disposition: inline
In-Reply-To: <1322449568.7454.35.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 03:06:08AM +0000, Ben Hutchings wrote:

> Any headers included by drivers should be under include/, and
> any definitions they use are not really private to the core as
> the name "dsa_priv.h" suggests.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
