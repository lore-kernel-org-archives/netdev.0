From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] r8152: improvement and new features
Date: Tue, 18 Feb 2014 16:41:01 -0500 (EST)
Message-ID: <20140218.164101.1698700144741352599.davem@davemloft.net>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 18 Feb 2014 21:48:57 +0800

> Change some flows or behavior to improve the efficiency or make the
> code readable. Besides, support WOL and runtime suspend.

Series applied, but as Florian mentioned you should seriously consider
converting this driver to use phylib.
