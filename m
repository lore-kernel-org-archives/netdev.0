From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6] Fix a typo in datagram.c
Date: Thu, 02 Dec 2010 09:35:00 +0800
Message-ID: <4CF6F7C4.1010509@cn.fujitsu.com>
References: <AANLkTin21SMZ8Oe5yagYkk+3ZZtfXF4iEyMnwaryFExa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59071 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755969Ab0LBBgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 20:36:41 -0500
In-Reply-To: <AANLkTin21SMZ8Oe5yagYkk+3ZZtfXF4iEyMnwaryFExa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz wrote, at 12/02/2010 03:46 AM:
> Hi,
> This path fixes a typo in net/core/datagram.c

This typo does not influence our reading. right?
And, you lost some ones.

$ grep -r corrent .
./net/core/datagram.c:		 * However, this function was corrent in any case. 8)
./net/sctp/socket.c:		 *  However, this function was corrent in any case. 8)
./drivers/serial/max3107.c:	/* if can't find the corrent config, use previous */
./drivers/gpu/drm/i915/intel_hdmi.c:	/* XXX first guess at handling video port, is this corrent? */

-- 
Best Regards
-----
Shan Wei

> 
> Regards,
> David Shwartz
> 
> Signed-off-by: David Shwartz <dshwatrz@gmail.com>




