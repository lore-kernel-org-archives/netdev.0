From: David Miller <davem@davemloft.net>
Subject: Re: [NET] mcs7830 passes msecs instead of jiffies to
 usb_control_msg
Date: Mon, 07 Jan 2008 23:16:01 -0800 (PST)
Message-ID: <20080107.231601.142992483.davem@davemloft.net>
References: <134b1d6c0801071520h9932537ke0b5daeaabab289b@mail.gmail.com>
	<20080107.214826.153054474.davem@davemloft.net>
	<1199776179.26870.1.camel@russ-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russ.Dill@asu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755932AbYAHHQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 02:16:02 -0500
In-Reply-To: <1199776179.26870.1.camel@russ-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russ Dill <Russ.Dill@asu.edu>
Date: Tue, 08 Jan 2008 00:09:39 -0700

> usb_control_msg was changed long ago (2.6.12-pre) to take milliseconds
> instead of jiffies. Oddly, mcs7830 wasn't added until 2.6.19-rc3.
> 
> Signed-off-by: Russ Dill <Russ.Dill@asu.edu>

Applied, thanks Russ.
