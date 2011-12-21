From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and
 buffer offset types
Date: Tue, 20 Dec 2011 23:48:34 -0500 (EST)
Message-ID: <20111220.234834.1265302793309771407.davem@davemloft.net>
References: <1324430940.2844.144.camel@deadeye>
	<1324431172.2844.147.camel@deadeye>
	<1324431746.2844.161.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837Ab1LUEsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 23:48:40 -0500
In-Reply-To: <1324431746.2844.161.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 21 Dec 2011 01:42:26 +0000

> I accidentally left signing enabled for this one, which I had intended
> to disable since you've said that patchwork doesn't deal with
> signatures.  Except this looks OK on patchwork:
> <http://patchwork.ozlabs.org/patch/132548/>.
> 
> If that also looks OK to you, is there any reason to avoid signing
> networking patches?

What do you mean exactly by "signing".

Do you mean simply the "Signed-off-by: " tag, which you should always
add to your own patches, or something else?
