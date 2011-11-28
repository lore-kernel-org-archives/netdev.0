From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/3] dsa: Remove unnecessary exports
Date: Mon, 28 Nov 2011 22:13:15 +0100
Message-ID: <20111128211315.GY795@wantstofly.org>
References: <1322449506.7454.34.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:63731 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab1K1VNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:13:18 -0500
Content-Disposition: inline
In-Reply-To: <1322449506.7454.34.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 03:05:06AM +0000, Ben Hutchings wrote:

> I mistakenly exported functions from slave.c that are only called from
> dsa.c, part of the same module.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
