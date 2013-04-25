From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 25 Apr 2013 15:00:37 +0200
Message-ID: <31069626.P6o3dNSz8U@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1436202.ggQbKKzqIM@linux-5eaq.site> <1366806685.4265.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>,
	Alan Stern <stern@rowland.harvard.edu>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:45414 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab3DYM7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:59:44 -0400
In-Reply-To: <1366806685.4265.3.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 24 April 2013 07:31:25 Dan Williams wrote:

> So how do we go forward from here...  I'm happy to update the patchset
> with anything needed to get davem to apply it.  Have we decided to keep
> the memflags for now, and thus should I just resubmit with a summary of
> the discussion under the ---?
> 
> If for whatever reason we do find out the memflags aren't really needed,
> they can always be removed later since this isn't userspace API.  But I
> think they're useful at this point.

I suggest if Ming Lei doesn't comment till Friday, please resubmit as is.

	Regards
		Oliver
