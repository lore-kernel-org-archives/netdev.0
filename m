From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Driver for Solos PCI ADSL2+ card.
Date: Tue, 23 Dec 2008 14:39:55 +0000
Message-ID: <1230043195.22786.480.camel@macbook.infradead.org>
References: <200812231427.mBNEREd3026407@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Nathan Williams <nathan@traverse.com.au>,
	Guy Ellis <guy@traverse.com.au>, Danny@xrio.com
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39786 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbYLWOkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 09:40:18 -0500
In-Reply-To: <200812231427.mBNEREd3026407@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-23 at 09:27 -0500, Chas Williams (CONTRACTOR) wrote:
> should make this an atomic type.  there is no locking/serialization in
> the vcc open/close unless you implement it yourself.

True. Actually I intend to remove it completely.

-- 
dwmw2

