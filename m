From: Amit Kale <amitkale@netxen.com>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 13:58:34 +0530
Message-ID: <200702121358.34712.amitkale@netxen.com>
References: <200702082152.19772.amitkale@netxen.com> <200702121333.16199.amitkale@netxen.com> <200702120912.56487.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:45164 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933110AbXBLI2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 03:28:48 -0500
In-Reply-To: <200702120912.56487.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 February 2007 13:42, Andi Kleen wrote:
> On Monday 12 February 2007 09:03, Amit Kale wrote:
> > The already released kernel contains a broken driver.  It broke due to
> > some code rearrangement changes someone submitted to fix sparse warnings.
>
> You mean it doesn't compile?

It compiles, but doesn't work if tried on real hardware.
We'll send a fix for the same in a few hours.
-Amit

>
> -Andi
