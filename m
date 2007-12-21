From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/10] sysfs network namespace support
Date: Thu, 20 Dec 2007 19:07:32 -0800
Message-ID: <20071221030732.GA16122@kroah.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59909 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbXLUDIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:08:53 -0500
Content-Disposition: inline
In-Reply-To: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 02:06:58AM -0700, Eric W. Biederman wrote:
> 
> Now that we have network namespace support merged it is time to
> revisit the sysfs support so we can remove the dependency on !SYSFS.

<snip>

Oops, I forgot to apply this to my tree.  Eric, you still want this
submitted, right?

thanks,

greg k-h
