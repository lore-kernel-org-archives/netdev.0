From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH] net/wireless/ti/wlcore/spi: Use module_spi_driver to
 register driver
Date: Mon, 17 Jun 2013 12:23:14 +0300
Message-ID: <1371460994.3028.8.camel@cumari.coelho.fi>
References: <1369079560-6101-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Felipe Balbi <balbi@ti.com>, Ido Yariv <ido@wizery.com>,
	Arik Nemtsov <arik@wizery.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Peter Huewe <peterhuewe@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369079560-6101-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 21:52 +0200, Peter Huewe wrote:
> Removing some boilerplate by using module_spi_driver instead of calling
> register and unregister in the otherwise empty init/exit functions
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
> ---

Applied.  Thanks, Peter.

--
Luca.
