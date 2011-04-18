From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: cosmetics: Using ethtool_cmd_speed() API
Date: Sun, 17 Apr 2011 23:29:10 -0700 (PDT)
Message-ID: <20110417.232910.245382216.davem@davemloft.net>
References: <1302833494-22266-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302833494-22266-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Thu, 14 Apr 2011 19:11:34 -0700

> This updates bnx2x to use the ethtool_cmd_speed() family of functions
> (see b11f8d8c in 2.6.27-rc3 aka. "ethtool: Expand ethtool_cmd.speed to
> 32 bits") to get and set the link speed via ethtool. This allows to
> avoid manually accessing ethtool_cmd's speed_hi field.
> 
> Signed-off-by: David Decotigny <decot@google.com>

Applied, thank you.
