From: Greg KH <greg@kroah.com>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Mon, 3 Nov 2008 11:55:37 -0800
Message-ID: <20081103195537.GA12922@kroah.com>
References: <20081103122512.06063fc9@mailhost.serverengines.com> <20081103193641.GA12552@kroah.com> <490F5667.3080904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:44966 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750974AbYKCUXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:23:08 -0500
Content-Disposition: inline
In-Reply-To: <490F5667.3080904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 02:52:07PM -0500, Jeff Garzik wrote:
> Greg KH wrote:
>> On Mon, Nov 03, 2008 at 04:25:12AM -0800, Subbu Seetharaman wrote:
>>> If we could get more specific feedback about the areas that require
>>> cleanup, we can take care of them quickly.  
>>> Since the last posting, we have brought up the driver in a PPC system
>>> and fixed some endianness issues.  As soon as I have some specific
>>> feedback, we can update the driver with these fixes as well.
>>>
>>> Please let me know as soon as the driver is in the staging area.
>> Does someone have a pointer to the driver, so that we can see what is
>> needed to be done?
>
> It was in my email :)  Repeating,
>
> The 'benet' branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>
> It should be suitable for pulling directly into staging.

Ah, sorry, missed that :)

I'll pull it in and post what I find.

thanks,

greg k-h
