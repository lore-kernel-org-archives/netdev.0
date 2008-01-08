From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] kaweth was forgotten in msec switchover of
 usb_start_wait_urb
Date: Mon, 07 Jan 2008 21:48:26 -0800 (PST)
Message-ID: <20080107.214826.153054474.davem@davemloft.net>
References: <134b1d6c0801071520h9932537ke0b5daeaabab289b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zapman@interlan.net, stephane@u-picardie.fr, bhards@bigpond.net.au,
	oliver@neukum.org, netdev@vger.kernel.org
To: Russ.Dill@asu.edu, russd@asu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751971AbYAHFs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:48:27 -0500
In-Reply-To: <134b1d6c0801071520h9932537ke0b5daeaabab289b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Russell Dill" <russd@asu.edu>
Date: Mon, 7 Jan 2008 16:20:20 -0700

> Back in 2.6.12-pre, usb_start_wait_urb was switched over to take
> milliseconds instead of jiffies. kaweth.c was never updated to match.
> 
> Signed-off-by: Russ Dill <Russ.Dill@asu.edu>

Applied, thanks.
