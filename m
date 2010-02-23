From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/7] xfrm by MARK
Date: Mon, 22 Feb 2010 16:21:52 -0800 (PST)
Message-ID: <20100222.162152.63475772.davem@davemloft.net>
References: <xfrm-mark-v3>
	<1266874380-29593-1-git-send-email-hadi@cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52113
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115Ab0BWAVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 19:21:38 -0500
In-Reply-To: <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 22 Feb 2010 16:32:53 -0500

> This patchset implements manipulation of ipsec tables with the
> "mark" tag. You can config the SAD and SPD from user space
> with a specified mark. 

Looks good, all applied to net-next-2.6, thanks!
