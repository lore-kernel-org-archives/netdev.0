From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] staging: at76_usb convert to netdev_ops
Date: Wed, 1 Apr 2009 13:24:09 -0400
Message-ID: <20090401172409.GD1443@bombadil.infradead.org>
References: <20090331201850.GC25513@bombadil.infradead.org> <20090331.141139.188200200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kyle@mcmartin.ca, gregkh@suse.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45705 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbZDARYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 13:24:16 -0400
Content-Disposition: inline
In-Reply-To: <20090331.141139.188200200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 02:11:39PM -0700, David Miller wrote:
> From: Kyle McMartin <kyle@mcmartin.ca>
> Date: Tue, 31 Mar 2009 16:18:50 -0400
> 
> > Didn't see this in your patch queue, fixes build on Fedora, though we'll
> > probably end up turning on CONFIG_COMPAT_NET_DEV_OPS for now anyway.
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>
>

Oops,

Alexander Beregalov already submitted this. My mistake, must have missed
it when I scanned for a fix...

cheers, Kyle
