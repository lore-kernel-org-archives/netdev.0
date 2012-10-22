From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Mon, 22 Oct 2012 13:59:09 -0400 (EDT)
Message-ID: <20121022.135909.1282399641501646286.davem@davemloft.net>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jean@google.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 22 Oct 2012 16:05:53 +0800

> Enable ALDPS function to save power when link down. Note that the
> feature should be set after the other PHY settings. And the firmware
> is necessary. Don't enable it without loading the firmware.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

If there are two patches in this series, which the Subject line
implies, where is the second patch?
