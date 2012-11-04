From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] r8169: enable internal ASPM and clock
 request settings
Date: Sun, 04 Nov 2012 01:01:35 -0500 (EST)
Message-ID: <20121104.010135.1162785749638710718.davem@davemloft.net>
References: <1351780651-1271-1-git-send-email-hayeswang@realtek.com>
	<1351824388-1225-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, agnescheng@google.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351824388-1225-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 2 Nov 2012 10:46:28 +0800

> The following chips need to enable internal settings to let ASPM
> and clock request work.
> 
> RTL8111E-VL, RTL8111F, RTL8411, RTL8111G
> RTL8105, RTL8402, RTL8106
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Francois?
