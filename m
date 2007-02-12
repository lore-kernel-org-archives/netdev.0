From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 08:29:50 +0000
Message-ID: <20070212082950.GD4095@ftp.linux.org.uk>
References: <200702082152.19772.amitkale@netxen.com> <p734ppw349e.fsf@bingen.suse.de> <200702121333.16199.amitkale@netxen.com> <200702120912.56487.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Kale <amitkale@netxen.com>, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49250 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933112AbXBLI3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 03:29:53 -0500
Content-Disposition: inline
In-Reply-To: <200702120912.56487.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 09:12:56AM +0100, Andi Kleen wrote:
> On Monday 12 February 2007 09:03, Amit Kale wrote:
> > The already released kernel contains a broken driver.  It broke due to some 
> > code rearrangement changes someone submitted to fix sparse warnings.
 
s/sparse warnings/breakage on big-endian boxen/, actually.  This stuff
was sent to netdev tree and sat there for a while.  Pity if some breakage
occured and went unnoticed; could you give more details?

> You mean it doesn't compile? 
