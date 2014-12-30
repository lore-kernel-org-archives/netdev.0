From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 3/3] net: ieee802154: don't use devm_pinctrl_get_select_default() in probe
Date: Mon, 29 Dec 2014 22:17:43 -0800
Message-ID: <6FEBBFCF-765F-4324-A9B1-92E47826F24A@holtmann.org>
References: <1419286616-9893-1-git-send-email-wsa@the-dreams.de> <1419286616-9893-3-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-gpio@vger.kernel.org, Varka Bhadram <varkabhadram@gmail.com>,
	Alexander Aring <alex.aring@gmail.com>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1419286616-9893-3-git-send-email-wsa@the-dreams.de>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wolfram,

> Since commit ab78029ecc34 (drivers/pinctrl: grab default handles from device
> core), we can rely on device core for setting the default pins.
> 
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
> ---
> drivers/net/ieee802154/cc2520.c | 7 -------
> 1 file changed, 7 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel

