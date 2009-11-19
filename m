From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Thu, 19 Nov 2009 10:07:21 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
References: <20091119163908.GJ14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amit Salecha <amit.salecha@qlogic.com>
To: Jens Rosenboom <me@jayr.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27420 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbZKSSI1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 13:08:27 -0500
In-Reply-To: <20091119163908.GJ14661@jayr.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My netxen 10G card stops working somewhere between 2.6.30 and 2.6.31-rc1.
> With the
> newer kernel I can see packets been received on the switch it is
> connected to, but
> the kernel doesn't report any sent packets in the interface counters and
> nothing
> is being received either.
> 
> I've tried to bisect this, but only seems the end up with kernels that do
> not boot
> at all because some SCSI stuff goes bad.

Any particular reason for using -rc1 kernel and not 2.6.31 stable kernel?

-Dhananjay
