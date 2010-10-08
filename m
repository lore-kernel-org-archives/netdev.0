From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 08 Oct 2010 11:50:50 -0700 (PDT)
Message-ID: <20101008.115050.28825457.davem@davemloft.net>
References: <20101008180310.GA27126@srcf.ucam.org>
	<20101008.111406.246542521.davem@davemloft.net>
	<20101008181851.GA27756@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ellyjones@google.com, netdev@vger.kernel.org, jglasgow@google.com,
	msb@google.com, olofj@google.com
To: mjg59@srcf.ucam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756689Ab0JHSu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 14:50:29 -0400
In-Reply-To: <20101008181851.GA27756@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@srcf.ucam.org>
Date: Fri, 8 Oct 2010 19:18:51 +0100

> On Fri, Oct 08, 2010 at 11:14:06AM -0700, David Miller wrote:
> 
>> I don't think we want a driver in the tree for a device for which the
>> firmware isn't even distributable.
> 
> Greg didn't seem to think this was a problem when he merged the serial 
> driver.

That's Greg's problem.

I don't see how any distribution can properly support this device
if it cannot work without non-distributable firmware.
