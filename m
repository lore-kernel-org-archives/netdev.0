From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 11/11] drivers/uwb: Rename dev_info to wdi
Date: Mon, 05 Apr 2010 14:44:18 -0700
Message-ID: <1270503858.31062.43.camel@Joe-Laptop.home>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
	 <6bd4d4dacf32631b72c3827a3b133a26e2e8b889.1270493677.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@csr.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1400 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756407Ab0DEVoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 17:44:20 -0400
In-Reply-To: <6bd4d4dacf32631b72c3827a3b133a26e2e8b889.1270493677.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-05 at 12:05 -0700, Joe Perches wrote:
> There is a macro called dev_info that prints struct device specific
> information.  Having variables with the same name can be confusing and
> prevents conversion of the macro to a function.
> 
> Rename the existing dev_info variables to something else in preparation
> to converting the dev_info macro to a function.

http://patchwork.ozlabs.org/patch/49421/

This marked as RFC in patchwork.
It's not intended to be.


