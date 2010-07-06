From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hp100: Use the instance of net_device_stats from
 net_device.
Date: Mon, 05 Jul 2010 19:07:08 -0700 (PDT)
Message-ID: <20100705.190708.15262120.davem@davemloft.net>
References: <1278332028-16769-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, perex@perex.cz, jpirko@redhat.com,
	adobriyan@gmail.com, shemminger@vyatta.com, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48279
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757406Ab0GFCGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:06:54 -0400
In-Reply-To: <1278332028-16769-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon,  5 Jul 2010 16:13:46 +0400

> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the adapter structure.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
