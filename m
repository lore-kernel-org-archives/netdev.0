From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 1/5] virtio_net: Allow setting the MAC address of the
 NIC
Date: Mon, 19 Jan 2009 09:32:30 +0000
Message-ID: <1232357550.5627.16.camel@blaa>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211318.22836.87192.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39498 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522AbZASJcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 04:32:36 -0500
In-Reply-To: <20090116211318.22836.87192.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-16 at 14:13 -0700, Alex Williamson wrote:
> Many physical NICs let the OS re-program the "hardware" MAC
> address.  Virtual NICs should allow this too.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Mark McLoughlin <markmc@redhat.com>

Cheers,
Mark.

