From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] virtio: Use __skb_queue_purge()
Date: Mon, 26 May 2008 16:11:47 +0800
Message-ID: <483A70C3.40507@cn.fujitsu.com>
References: <200805261742.43215.rusty@rustcorp.com.au> <200805261748.13449.rusty@rustcorp.com.au> <200805261753.23860.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65082 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbYEZIOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 04:14:39 -0400
In-Reply-To: <200805261753.23860.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell said the following on 2008-5-26 15:53:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Use standard routine for queue purging.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Rusty, Jeff has applied this one and David has merged it and
send a pull request to Linus.
Thanks.

