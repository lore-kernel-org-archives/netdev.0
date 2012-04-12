From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Remove CONFIG_WIZNET_TX_FLOW option
Date: Thu, 12 Apr 2012 15:46:17 -0400 (EDT)
Message-ID: <20120412.154617.1852535448842801656.davem@davemloft.net>
References: <1334211288-7682-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: msink@permonline.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334211288-7682-1-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Sinkovsky <msink@permonline.ru>
Date: Thu, 12 Apr 2012 12:14:48 +0600

> This option was there for debugging race conditions,
> just remove it, and assume TX_FLOW is always enabled.
> 
> Signed-off-by: Mike Sinkovsky <msink@permonline.ru>

Applied.
