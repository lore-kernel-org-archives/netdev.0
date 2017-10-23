From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] drivers/net/usb: add device id for TP-LINK UE300 USB
 3.0 Ethernet
Date: Mon, 23 Oct 2017 12:56:10 +0200
Message-ID: <1508756170.28673.7.camel@suse.com>
References: <20171023101023.5470-1-ran.wang_1@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        hayeswang <hayeswang@realtek.com>, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Ran Wang <ran.wang_1@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023101023.5470-1-ran.wang_1@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 23.10.2017, 18:10 +0800 schrieb Ran Wang:
> This product is named 'TP-LINK USB 3.0 Gigabit Ethernet Network
> Adapter (Model No.is UE300)'. It uses chip RTL8153 and works with
> driver drivers/net/usb/r8152.c
> 

Hi,

just for the record, have you confirm that it fails with cdc-ether?

	Regards
		Oliver
