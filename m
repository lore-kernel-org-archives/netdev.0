From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Fri, 21 Sep 2012 09:44:49 +0800
Message-ID: <CACVXFVO6BuboVV5y5PBCZORNBNQuDzovCQL6tMrxxM+ehymDAA@mail.gmail.com>
References: <87r4pxumdd.fsf@nemi.mork.no>
	<20120920.170227.258356702969458329.davem@davemloft.net>
	<1703568.mhE1zQzG7o@linux-lqwf.site>
	<20120920.171610.1120043891672310370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: oliver@neukum.org, bjorn@mork.no, gregkh@linuxfoundation.org,
	finik@ti.com, rjw@sisk.pl, stern@rowland.harvard.edu,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:51172 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab2IUBov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 21:44:51 -0400
In-Reply-To: <20120920.171610.1120043891672310370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 5:16 AM, David Miller <davem@davemloft.net> wrote:
> From: Oliver Neukum <oliver@neukum.org>
> Date: Thu, 20 Sep 2012 23:04:38 +0200
>
>> On Thursday 20 September 2012 17:02:27 David Miller wrote:
>>>
>>> There seems to be some discussion about the legitimacy of doing things
>>> this way, and in any event the patches were an RFC.
>>>
>>> Please resubmit as a non-RFC once all the issues have been worked
>>> out, if appropriate.
>>
>> Just to make this clear, I'd like to state that the discussion involved
>> only the third, last patch in the series. The first two are fine and make
>> sense by themselves.
>
> I want changes in those, see my replies.

No problem, I will send out -v2 of the first two patches later.

thanks,
--
Ming Lei
