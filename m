From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: DSA drivers in net/ vs drivers/net/
Date: Wed, 8 Apr 2009 12:12:42 +0200
Message-ID: <20090408101242.GZ4738@xi.wantstofly.org>
References: <53D98710-2AA9-42D8-A478-40B51303678B@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:33082 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420AbZDHKMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 06:12:44 -0400
Content-Disposition: inline
In-Reply-To: <53D98710-2AA9-42D8-A478-40B51303678B@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2009 at 11:58:05PM -0500, Kumar Gala wrote:

> Lennert,

Hi Kumar,


> Was glancing over the DSA code and was wondering if there was any  
> reason we have the actual drivers for the various chips in net/ vs  
> drivers/net/dsa/

No real good reason, I guess.  I'd be happy to move the individual
chip drivers under drivers/net/dsa/.


thanks,
Lennert
