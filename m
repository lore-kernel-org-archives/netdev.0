From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Add ethtool WOL support
Date: Sun, 25 Jul 2010 16:48:55 -0700 (PDT)
Message-ID: <20100725.164855.193718303.davem@davemloft.net>
References: <201007250524.18911.andrew@beldisplaytech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bugzilla@tut.by, andrew@beldisplaytech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658Ab0GYXsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 19:48:38 -0400
In-Reply-To: <201007250524.18911.andrew@beldisplaytech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andrew O. Shadoura" <andrew@beldisplaytech.com>
Date: Sun, 25 Jul 2010 05:24:17 +0300

> This patch adds wrappers for ethtool to get or set wake-on-LAN 
> setting without re-inserting the kernel module.
> 
> Signed-off-by: Andrew O. Shadoura <andrew@beldisplaytech.com>

Applied, thanks.
