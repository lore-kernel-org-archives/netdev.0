From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: support ndo_features_check
Date: Tue, 06 Jan 2015 13:30:40 -0500 (EST)
Message-ID: <20150106.133040.1248555811773223317.davem@davemloft.net>
References: <1394712342-15778-113-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-113-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 6 Jan 2015 17:41:58 +0800

> Support ndo_features_check to avoid:
>  - the transport offset is more than the hw limitation when using hw checksum.
>  - the skb->len of a GSO packet is more than the limitation.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
