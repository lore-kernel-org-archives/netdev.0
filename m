From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET DRIVER: Added support for Cinterion's PLxx WWAN
 Interface
Date: Mon, 06 May 2013 10:26:42 -0400 (EDT)
Message-ID: <20130506.102642.62606210058731110.davem@davemloft.net>
References: <239D7A53E5B17B4BB20795A7977613A4A7EE9993A8@CROEXCFWP04.gemalto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hans-Christoph.Schemmel@gemalto.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <239D7A53E5B17B4BB20795A7977613A4A7EE9993A8@CROEXCFWP04.gemalto.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>
Date: Mon, 6 May 2013 11:16:46 +0200

> /drivers/net/usb/qmi_wwan.c: Added support for Cinterion's PLxx WWAN Interface by adding QMI_FIXED_INTF with Cinterion's Vendor ID as well as Product ID and WWAN Interface Number.
> 
> Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>

The Subject needs to use lowercase letters for the "prefix: " bit
coming after "[PATCH]" and use a more appropropate area indication.

"qmi_wwan: " would have been more appropriate.

Also, properly text format your commit messages so that lines are no longer
than 80 columns.

Just because it looks like it's properly formatted on your computer screen
doesn't mean it is.
