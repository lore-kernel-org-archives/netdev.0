From: Amit Kale <amitkale@netxen.com>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 13:59:54 +0530
Message-ID: <200702121359.54363.amitkale@netxen.com>
References: <200702082152.19772.amitkale@netxen.com> <200702121333.16199.amitkale@netxen.com> <200702120912.56487.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:21917 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933111AbXBLI3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 03:29:39 -0500
In-Reply-To: <200702120912.56487.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sending it again from correct smtp server.

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
