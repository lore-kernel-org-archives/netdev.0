From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] net/usb: Misc. fixes for the LG-VL600 LTE USB
 modem
Date: Mon, 14 Nov 2011 00:49:29 -0500 (EST)
Message-ID: <20111114.004929.384609475492837593.davem@davemloft.net>
References: <1320875290-29407-1-git-send-email-prox@prolixium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@suse.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: prox@prolixium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320875290-29407-1-git-send-email-prox@prolixium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Kamichoff <prox@prolixium.com>
Date: Wed,  9 Nov 2011 16:48:10 -0500

> Add checking for valid magic values (needed for stability in the event
> corrupted packets are received) and remove some other unneeded checks.
> Also, fix flagging device as WWAN (Bugzilla bug #39952).
> 
> Signed-off-by: Mark Kamichoff <prox@prolixium.com>

Applied, thanks Mark.
