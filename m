From: David Miller <davem@davemloft.net>
Subject: Re: MIPS: BCM63XX: Add integrated ethernet mac support.
Date: Tue, 07 Jul 2009 19:26:58 -0700 (PDT)
Message-ID: <20090707.192658.31078101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48944
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbZGHC04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:26:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I can't apply this to net-next-2.6 beause it depends upon
the patches that add arch/mips/bcm63xx etc.

So Ralf you can add this to your tree and feel free to add
my signoff:

Signed-off-by: David S. Miller <davem@davemloft.net>
