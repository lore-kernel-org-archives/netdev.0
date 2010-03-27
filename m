From: David Miller <davem@davemloft.net>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Fri, 26 Mar 2010 20:21:25 -0700 (PDT)
Message-ID: <20100326.202125.238456279.davem@davemloft.net>
References: <20090329053513.GD19602@colo.lackof.org>
	<20090328.235931.45430524.davem@davemloft.net>
	<20100207071540.GA9908@lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kyle@mcmartin.ca, netdev@vger.kernel.org, error27@gmail.com
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477Ab0C0DVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:21:02 -0400
In-Reply-To: <20100207071540.GA9908@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Sun, 7 Feb 2010 00:15:40 -0700

> On Sat, Mar 28, 2009 at 11:59:31PM -0700, David Miller wrote:
> ...
>> > Patch below looks right to me. Clobbering the skb is certainly wrong.
>> > 
>> > Acked-by: Grant Grundler <grundler@parisc-linux.org>
>> 
>> It looks correct to me, can we get a proper submission with
>> signoffs etc.?
> 
> Dave,
> Looks like this patch was never resubmitted.
> 
> Kyle, can you look at http://lists.openwall.net/netdev/2009/03/27/117
> and resubmit the code you had then with my "Acked-by" added please?
> 
> Or if you don't want to touch it, let me know and I'll resurrect it.

I got tired of waiting for this resubmission (a month and a half) and
just applied the most recent version of the patch to net-2.6.

It looked correct to me too.
