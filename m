From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] C/R: Add checkpoint and collect hooks to
 net_device_ops
Date: Fri, 26 Feb 2010 04:08:22 -0800 (PST)
Message-ID: <20100226.040822.113445974.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934992Ab0BZMIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:08:04 -0500
In-Reply-To: <1267130595-23637-2-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:10 -0800

> These will be implemented per-driver by those that support such
> operations.
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
