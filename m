From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/usb/r8152 fix broken rx checksums
Date: Sun, 30 Oct 2016 17:22:22 -0400 (EDT)
Message-ID: <20161030.172222.1243045598122436637.davem@davemloft.net>
References: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: mlord@pobox.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <mlord@pobox.com>
Date: Wed, 26 Oct 2016 18:36:57 -0400

> Patch attached (to deal with buggy mailer) and also below for review.

Please make your mailer work properly so that you can submit
patches properly which work inline, just like every other developer
does for the kernel.

Also please format your Subject line properly, it must be of the
form:

	[PATCH net] r8152: Fix broken RX checksums.

The important parts are:

	1) "[PATCH net]"  This says that it is a patch, and that it
	   is targetting the 'net' GIT tree specifically.

	2) "r8152: "  This indicates the "subsystem" that the patch
	   specifically targets, in this case the r8152 driver.  It
	   must end with a colon character then a space.

	3) "Fix broken RX checksums."  Commit header lines and commit
	   messages are proper English, therefore sentences should
	   begin with a capitalized letter and end with a period.

Thanks.
