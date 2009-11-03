From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next] iwmc3200bt: Add iwmc3200 bluetooth driver
Date: Tue, 03 Nov 2009 10:40:25 +0900
Message-ID: <1257212425.3420.2.camel@localhost.localdomain>
References: <1257204990-18669-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-mmc@vger.kernel.org,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: Tomas Winkler <tomas.winkler@intel.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1257204990-18669-1-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> Add Intel Wireless MultiCom 3200 SDIO BT driver
> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
> wmc3200bt is derived from btsdio driver

just a heads up, this is not a net-next patch. This clearly goes via
proper review on linux-bluetooth and bluetooth-next tree first. So
please don't pull until I ack it.

Tomas, please try not to jump the gun here.

Regards

Marcel


