From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 2/2] net/usb/mcs7830: add set_mac_address
Date: Tue, 26 Aug 2008 13:47:38 -0700
Message-ID: <200808261347.38859.david-b@pacbell.net>
References: <200808232202.23822.arnd@arndb.de> <200808232208.47578.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Oliver Martin <oliver.martin@student.tuwien.ac.at>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:29072 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751250AbYHZUrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 16:47:43 -0400
In-Reply-To: <200808232208.47578.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 August 2008, Arnd Bergmann wrote:
> From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
> 
> Implement set_mac_address for mcs7830. This enables me to use it with my
> cable modem. Tested (and using it right now) with 2.6.26, tested to
> compile with 2.6.27-rc4
> 
> Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
 
For what it's worth:

  Acked-by: David Brownell <dbrownell@users.sourceforge.net>

You might consider adding yourself as maintainer for this driver.
