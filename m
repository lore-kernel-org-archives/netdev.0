From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RX/close vcc race with solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 11:02:50 +0100
Message-ID: <1275904970.17903.4658.camel@macbook.infradead.org>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nathan Williams <nathan@traverse.com.au>
To: linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45698 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197Ab0FGKCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 06:02:54 -0400
In-Reply-To: <1274872584.20576.13579.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-26 at 12:16 +0100, David Woodhouse wrote:
> I've had this crash reported to me...
> 
> [18842.727906] EIP: [<e082f490>] br2684_push+0x19/0x234 [br2684]
> SS:ESP 0068:dfb89d14 

Nathan, did you manage to get your customer to confirm that this fixes
the problem? It'd be useful to get this into 2.6.35 and -stable.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

