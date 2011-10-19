From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: asix: fix ethtool -e for AX88178 USB dongle
Date: Wed, 19 Oct 2011 19:31:24 -0400 (EDT)
Message-ID: <20111019.193124.1671539300674527473.davem@davemloft.net>
References: <1318866666-956-1-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318866666-956-1-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Mon, 17 Oct 2011 08:51:06 -0700

> "ethtool -e ethX" dumps EEPROM data. Patch sets EEPROM length for device.
> Ethtool works alot better when the kernel believes the length is > 0.
> 
> From: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied to net-next, thanks.
