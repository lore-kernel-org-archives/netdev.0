From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH 0/3 net] Add iwmc3200top driver
Date: Wed, 23 Sep 2009 02:38:41 +0300
Message-ID: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com
To: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

iwmc3200top: Add Intel Wireless MultiCom 3200 top driver.
iwmc3200wifi: select IWMC3200TOP in Kconfig
i2400m-sdio: select IWMC3200TOP in Kconfig

Add iwmc3200top driver. Imwc3200 is under drivers/misc driver but IMWC network 
drivers depends on it therefore submitted through netdev


---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

