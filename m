From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] Add ethtool -g support to virtio_net
Date: Mon, 24 Oct 2011 07:31:05 +0200
Message-ID: <20111024053103.GA24528@redhat.com>
References: <20111019181059.C644A29003F6@tardy>
 <8762jk2j2r.fsf@rustcorp.com.au>
 <20111023.232604.18246342474494526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, raj@tardy.cup.hp.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736Ab1JXFap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 01:30:45 -0400
Content-Disposition: inline
In-Reply-To: <20111023.232604.18246342474494526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 23, 2011 at 11:26:04PM -0400, David Miller wrote:
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

Please do, thanks very much.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

-- 
MST
