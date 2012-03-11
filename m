From: David Miller <davem@davemloft.net>
Subject: Re: Patch for Sitecom LN-031
Date: Sun, 11 Mar 2012 15:53:08 -0700 (PDT)
Message-ID: <20120311.155308.854791460127462538.davem@davemloft.net>
References: <1331282643.5426.6.camel@mobile>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j.neikes@midlandgate.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331282643.5426.6.camel@mobile>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Neikes <j.neikes@midlandgate.de>
Date: Fri, 09 Mar 2012 09:44:03 +0100

> This patch adds support for the Sitecom LN-031 USB adapter with a AX88178 chip.
> 
> Added USB id to find correct driver for AX88178 1000 Ethernet adapter.
> 
> Signed-off-by: Joerg Neikes <j.neikes@midlandgate.de>

Applied, but please put more appropriate content in your subject
lines in the future.

You should, at a minimum, prefix the subject line with the driver or
subsystem name you are modifying.  In this case something like
"asix: " would have been appropriate.
