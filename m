From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Convert char *name to const char *name
Date: Sun, 20 Feb 2011 17:32:59 +0300
Message-ID: <20110220143259.GA19984@ioremap.net>
References: <1298151834-13141-1-git-send-email-martinez.javier@gmail.com>
 <1298159129.7179.32.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org,
	"K. Y. Srinivasan" <ksrinivasan@novell.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:43114 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751875Ab1BTOdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 09:33:05 -0500
Content-Disposition: inline
In-Reply-To: <1298159129.7179.32.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe.

On Sat, Feb 19, 2011 at 03:45:29PM -0800, Joe Perches (joe@perches.com) wrote:
> Allow more const declarations.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> ---
> 
> Better to change the declarations and uses as this argument
> is not modified.

Looks good, thank you.
Greg, please push it into your tree.

Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
