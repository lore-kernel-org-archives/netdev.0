From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Mon, 03 Nov 2008 14:52:07 -0500
Message-ID: <490F5667.3080904@garzik.org>
References: <20081103122512.06063fc9@mailhost.serverengines.com> <20081103193641.GA12552@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40208 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbYKCTwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 14:52:12 -0500
In-Reply-To: <20081103193641.GA12552@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Mon, Nov 03, 2008 at 04:25:12AM -0800, Subbu Seetharaman wrote:
>> If we could get more specific feedback about the areas that require
>> cleanup, we can take care of them quickly.  
>>
>> Since the last posting, we have brought up the driver in a PPC system
>> and fixed some endianness issues.  As soon as I have some specific
>> feedback, we can update the driver with these fixes as well.
>>
>> Please let me know as soon as the driver is in the staging area.
> 
> Does someone have a pointer to the driver, so that we can see what is
> needed to be done?

It was in my email :)  Repeating,

The 'benet' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

It should be suitable for pulling directly into staging.

	Jeff


