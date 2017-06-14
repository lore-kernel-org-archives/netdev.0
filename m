From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: update undefined ->ndo_change_mtu() comment
Date: Wed, 14 Jun 2017 15:15:09 -0400 (EDT)
Message-ID: <20170614.151509.1313996001570477876.davem@davemloft.net>
References: <149742452429.31376.14849833346784081961.sendpatchset@little-apple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149742452429.31376.14849833346784081961.sendpatchset@little-apple>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Wed, 14 Jun 2017 16:15:24 +0900

> From: Magnus Damm <damm+renesas@opensource.se>
> 
> Update ->ndo_change_mtu() callback comment to remove text
> about returning error in case of undefined callback. This
> change makes the comment match the existing code behavior.
> 
> Signed-off-by: Magnus Damm <damm+renesas@opensource.se>

Applied, thanks Magnus.
