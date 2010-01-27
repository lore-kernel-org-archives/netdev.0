From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: Network QoS support in applications
Date: Wed, 27 Jan 2010 09:03:07 +0200
Message-ID: <874om8m3mc.fsf@purkki.valot.fi>
References: <87k4v5nuej.fsf@purkki.valot.fi> <4B5ED254.7010104@trash.net>
	<877hr5nkx0.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
	<189614e81eab48b8189ee99236902df3@petri-meat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Steven Blake <slblake@petri-meat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:57849 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab0A0HDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 02:03:10 -0500
In-Reply-To: <189614e81eab48b8189ee99236902df3@petri-meat.com> (Steven Blake's message of "Tue\, 26 Jan 2010 10\:29\:20 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steven Blake <slblake@petri-meat.com> writes:

>> This is a local policy decision.
>> 
>> There is no universal way of doing any of this, really.
>
> You are correct.  However, RFC 4594 is an attempt to get applications and
> network operators on the same page.  There is no harm done if apps set DSCP
> values in accordance with this RFC.

Wow, this is great. Somehow I missed this, thank you very much. I will
read it in detail now. 

DiffServ people should have written something like this from the
beginning.

-- 
Kalle Valo
