From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: fix the incorrect tx descriptor version
Date: Wed, 12 Mar 2014 00:11:57 -0400 (EDT)
Message-ID: <20140312.001157.1322660670638484760.davem@davemloft.net>
References: <1394521919-4257-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394521919-4257-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 11 Mar 2014 15:11:59 +0800

> The tx descriptor version of RTL8111B belong to RTL_TD_0.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thank you.
