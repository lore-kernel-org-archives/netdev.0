From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Mon, 15 Oct 2007 08:51:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710150849580.17284@netcore.fi>
References: <20071014111147.GE20850@mcdonald.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Andrew McDonald <andrew@mcdonald.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:47946 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbXJOGZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 02:25:31 -0400
In-Reply-To: <20071014111147.GE20850@mcdonald.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Took off linux-man from cc:,

On Sun, 14 Oct 2007, Andrew McDonald wrote:
> +The tapped packets are not forwarded by the kernel, it is the
> +user's responsibility to send them out again.

This is probably incompliant (and from users' perspective, 
unacceptible) behaviour that IMHO should be fixed.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
