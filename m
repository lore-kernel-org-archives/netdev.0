From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] C/R: Add a checkpoint handler to the 'sit' device
Date: Fri, 26 Feb 2010 04:09:29 -0800 (PST)
Message-ID: <20100226.040929.231214823.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934992Ab0BZMJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:09:11 -0500
In-Reply-To: <1267130595-23637-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:14 -0800

> This handler doesn't really do much to checkpoint the device, other
> than the minimum required to support the restart process.  When we
> add IPv6 support to this, then we can fill this out.
> 
> This allows us to avoid skipping unsupported interfaces on a normal
> system.
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
