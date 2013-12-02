From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] PCI / tg3: Give up chip reset and carrier loss
 handling if PCI device is not present
Date: Mon, 2 Dec 2013 10:54:57 -0800
Message-ID: <1386010497.6988.8.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <7807315.7cU9KldDtM@vostro.rjw.lan>
 <1385930359.6988.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20131202.134829.2041194874847967680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: rjw@rjwysocki.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-pci@vger.kernel.org, bhelgaas@google.com, nsujir@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20131202.134829.2041194874847967680.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-02 at 13:48 -0500, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Sun, 1 Dec 2013 12:39:19 -0800
> 
> > I'm not familiar with the DS1.  Does the tg3 device get removed through
> > tg3_remove_one() in this case?  What happens when you reconnect the DS1?
> 
> Michael, is Rafael's explanation sufficient for you?
> 

Yes, thanks.

Acked-by: Michael Chan <mchan@broadcom.com>
