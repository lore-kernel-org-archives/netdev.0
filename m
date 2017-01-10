From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] r8152: fix autosuspend issue
Date: Tue, 10 Jan 2017 11:50:56 -0500 (EST)
Message-ID: <20170110.115056.1281648951244918656.davem@davemloft.net>
References: <1394712342-15778-229-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-229-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 10 Jan 2017 17:04:05 +0800

> Avoid rx is split into two parts when runtime suspend occurs.

Series applied and queued up for -stable.
