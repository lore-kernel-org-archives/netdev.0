From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] Add ethtool -g support to virtio_net
Date: Mon, 24 Oct 2011 15:11:31 +1030
Message-ID: <87r5230zno.fsf@rustcorp.com.au>
References: <20111019181059.C644A29003F6@tardy> <8762jk2j2r.fsf@rustcorp.com.au> <20111023.232604.18246342474494526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raj@tardy.cup.hp.com, netdev@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57108 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018Ab1JXGMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 02:12:25 -0400
In-Reply-To: <20111023.232604.18246342474494526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Oct 2011 23:26:04 -0400 (EDT), David Miller <davem@davemloft.net> wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 20 Oct 2011 18:25:24 +1030
> 
> > On Wed, 19 Oct 2011 11:10:59 -0700 (PDT), raj@tardy.cup.hp.com (Rick Jones) wrote:
> >> From: Rick Jones <rick.jones2@hp.com>
> >> 
> >> Add support for reporting ring sizes via ethtool -g to the virtio_net
> >> driver.
> >> 
> >> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> > 
> > Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> > 
> > MST, want me to take this, or do you?
> 
> I can also take it directly, just let me know.

I'm happy with that.

Thanks,
Rusty.
