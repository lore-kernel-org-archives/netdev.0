From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Mon, 17 Nov 2008 17:38:54 +1030
Message-ID: <200811171738.55143.rusty@rustcorp.com.au>
References: <200811171344.57410.rusty@rustcorp.com.au> <20081116.194505.140648013.davem@davemloft.net> <20081116.224007.208486442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52394 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657AbYKQHJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 02:09:01 -0500
In-Reply-To: <20081116.224007.208486442.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 November 2008 17:10:07 David Miller wrote:
> Even with the mail client corruption fix this thing didn't even apply
> to net-next-2.6 :-(

Assume this is the netdev_priv changes.  I'll drop my versions from linux-next 
to avoid screwing Stephen over.

Thanks,
Rusty.

