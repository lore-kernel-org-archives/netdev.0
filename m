From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Thu, 15 Apr 2010 23:33:34 -0700 (PDT)
Message-ID: <20100415.233334.242114544.davem@davemloft.net>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56742
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752375Ab0DPGda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:33:30 -0400
In-Reply-To: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)

> Version 5 of RFS:
> - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as a
> static function.
> - Apply limits to rps_sock_flow_entires systcl and rps_flow_count
> sysfs variable.

I've read this over a few times and I think it's ready to go into
net-next-2.6, we can tweak things as-needed from here on out.

Eric, what do you think?
