From: Peter =?iso-8859-15?q?H=FCwe?= <PeterHuewe@gmx.de>
Subject: Re: [PATCH] net/ethernet/micrel/ks8851.c: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 22:09:15 +0200
Message-ID: <201305202209.16076.PeterHuewe@gmx.de>
References: <1369079776-6214-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Bill Pemberton <wfp5p@virginia.edu>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369079776-6214-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 20. Mai 2013, 21:56:16 schrieb Peter Huewe:
> Removing some boilerplate by using module_spi_driver instead of calling
> register and unregister in the otherwise empty init/exit functions
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>


Sorry for the noise 
 already exists in 3.10-rc1 by Lars-Peter Clausen
	0582ce92  net: ks8851: Use module_spi_driver	Lars-Peter Clausen

I was working on an stale tree - sorry.
Please ignore this patch.

Peter
