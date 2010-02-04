From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: CONFIG_COMPAT redux
Date: Wed, 03 Feb 2010 20:32:43 -0800 (PST)
Message-ID: <20100203.203243.257874267.davem@davemloft.net>
References: <20100201194418.GB21315@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757033Ab0BDEca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:32:30 -0500
In-Reply-To: <20100201194418.GB21315@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 1 Feb 2010 21:44:19 +0200

> Ifdef out
> 	struct proto_ops::compat_ioctl
> 	struct proto_ops::compat_setsockopt
> 	struct proto_ops::compat_getsockopt
> to make structures smaller on COMPAT=n kernels.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
