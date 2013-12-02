From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PCI / tg3: Give up chip reset and carrier loss
 handling if PCI device is not present
Date: Mon, 02 Dec 2013 13:48:29 -0500 (EST)
Message-ID: <20131202.134829.2041194874847967680.davem@davemloft.net>
References: <7807315.7cU9KldDtM@vostro.rjw.lan>
	<1385930359.6988.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@rjwysocki.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-pci@vger.kernel.org, bhelgaas@google.com, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385930359.6988.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 1 Dec 2013 12:39:19 -0800

> I'm not familiar with the DS1.  Does the tg3 device get removed through
> tg3_remove_one() in this case?  What happens when you reconnect the DS1?

Michael, is Rafael's explanation sufficient for you?
