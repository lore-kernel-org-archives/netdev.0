From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] VIRTIO: Use __skb_queue_purge()
Date: Fri, 23 May 2008 11:54:11 +1000
Message-ID: <200805231154.12188.rusty@rustcorp.com.au>
References: <483545EF.3070501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38871 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776AbYEWByZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 21:54:25 -0400
In-Reply-To: <483545EF.3070501@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 May 2008 20:07:43 Wang Chen wrote:
> Use standard routine for queue purging.
>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Thanks, applied.

Jeff, I'm planning on final testing of my 4 pending virtio_net patches for 
2.6.26 today: if all goes well, I'll send them in a neat batch.

Cheers,
Rusty.
