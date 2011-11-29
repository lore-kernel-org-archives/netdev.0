From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] dsa: Move all definitions needed by
 drivers into <net/dsa.h>
Date: Tue, 29 Nov 2011 01:20:23 -0500 (EST)
Message-ID: <20111129.012023.963837049622715590.davem@davemloft.net>
References: <1322449506.7454.34.camel@deadeye>
	<1322449568.7454.35.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab1K2GUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:20:35 -0500
In-Reply-To: <1322449568.7454.35.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 28 Nov 2011 03:06:08 +0000

> Any headers included by drivers should be under include/, and
> any definitions they use are not really private to the core as
> the name "dsa_priv.h" suggests.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
