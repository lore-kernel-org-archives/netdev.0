From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] virtio_net: indicate oom when addbuf returns
 failure
Date: Fri, 4 Jun 2010 09:05:40 -0700
Message-ID: <20100604160540.GB26004@kroah.com>
References: <201006041028.56798.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Bruce Rogers <brogers@novell.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:55091 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723Ab0FDQGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 12:06:55 -0400
Content-Disposition: inline
In-Reply-To: <201006041028.56798.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 04, 2010 at 10:28:56AM +0930, Rusty Russell wrote:
> This patch is a subset of an already upstream patch, but this portion
> is useful in earlier releases.

What is the git commit id of that upstream patch?

thanks,

greg k-h
