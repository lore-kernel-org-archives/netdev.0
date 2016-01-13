From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: fsl/fman: Clarification for implementation details in
 dtsec_config()
Date: Thu, 14 Jan 2016 00:35:37 +0300
Message-ID: <20160113213537.GD4399@mwanda>
References: <5696BFAD.9030905@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Igal Liberman <igal.liberman@freescale.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5696BFAD.9030905@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think you can remove the put_device() line.

regards,
dan carpenter
