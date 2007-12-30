From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Sun, 30 Dec 2007 12:20:57 +0000
Message-ID: <20071230122057.GA23931@nuim.ie>
References: <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
 <20071230011500.GA30997@nuim.ie> <20071230012549.GB30997@nuim.ie>
 <20071229.190917.130399687.davem@davemloft.net>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:57381 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751999AbXL3MUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 07:20:53 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTV006T83MPCF10@mango.nuim.ie> for
 netdev@vger.kernel.org; Sun, 30 Dec 2007 12:20:49 +0000 (GMT)
In-reply-to: <20071229.190917.130399687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 29 Dec 2007, David Miller wrote:

> Never mind about making the relative patch, I didn't want to have
> to wait for you to send me that and have it block my merge of
> fixes with Linus this evening.

Ah, sorry for the inconvenience.  I didn't realise you had merged it yet.

> The following is what I applied on top of your other patch:

That looks fine.

Gavin

