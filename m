From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] ep93xx_eth.c: general cleanup
Date: Wed, 16 Dec 2009 19:01:40 +0100
Message-ID: <20091216180132.GL1819@mail.wantstofly.org>
References: <BD79186B4FD85F4B8E60E381CAEE19090200ECE7@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:41126 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbZLPSBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 13:01:42 -0500
Content-Disposition: inline
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200ECE7@mi8nycmail19.Mi8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 12:29:38PM -0500, H Hartley Sweeten wrote:

> General cleanup of the ep93xx_eth driver.

Apart from keeping DRV_MODULE_NAME and DRV_MODULE_VERSION, I have
no strong opinion about this one way or the other.  So I guess that
means ACK.
