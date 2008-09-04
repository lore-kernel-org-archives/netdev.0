From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/15] netdevice 82596: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Thu, 04 Sep 2008 08:34:39 +0800
Message-ID: <48BF2D1F.4080306@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com> <48B3D7F8.6050708@cn.fujitsu.com> <48BE97BF.7010909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52338 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbYIDAhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 20:37:10 -0400
In-Reply-To: <48BE97BF.7010909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik said the following on 2008-9-3 21:57:
> Your code changes and description do not match...  did you intend
> ml_priv or netdev_priv() ?
> 


Yes. I am out of my mind that moment.
I will resend the patches, thanks Jeff.

