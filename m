From: Peter =?iso-8859-15?q?H=FCwe?= <PeterHuewe@gmx.de>
Subject: Re: [PATCH] net/ieee802154/mrf24j40: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 22:16:02 +0200
Message-ID: <201305202216.02400.PeterHuewe@gmx.de>
References: <1369079686-6160-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Eremin-Solenikov" <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369079686-6160-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 20. Mai 2013, 21:54:46 schrieb Peter Huewe:
> Removing some boilerplate by using module_spi_driver instead of calling
> register and unregister in the otherwise empty init/exit functions
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
Sorry for the noise 
 already exists in 3.10-rc1
3d4a131 mrf24j40: use module_spi_driver to simplify the code

I was working on an stale tree - sorry.
Please ignore this patch.

Peter
