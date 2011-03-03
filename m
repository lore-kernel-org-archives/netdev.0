From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mv643xx_eth: Use netdev_<level> and pr_<level>
Date: Thu, 3 Mar 2011 14:18:34 +0100
Message-ID: <20110303131834.GL16649@mail.wantstofly.org>
References: <1299124235.4208.129.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:59350 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab1CCNSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 08:18:37 -0500
Content-Disposition: inline
In-Reply-To: <1299124235.4208.129.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 07:50:35PM -0800, Joe Perches wrote:

> Use the current logging styles.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>


> I don't know if this module is still being maintained.

Maintained, yes, actively developed, no, but that's just because
there's not much left to be done, as it works pretty well (AFAICT).
