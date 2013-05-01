From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Thu, 2 May 2013 00:31:55 +0200
Message-ID: <20130501223155.GA15261@electric-eye.fr.zoreil.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lance Lassetter <lancelassetter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57791 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434Ab3EAWb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 18:31:58 -0400
Content-Disposition: inline
In-Reply-To: <20130501212803.GA3342@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lance Lassetter <lancelassetter@gmail.com> :
[...]
> Yes, it was an up to date Fedora 17.  I know this is probably redundant but
> I also tried Realtek firmware from a Debian Sid box onto the Fedora 18
> using testing repos with vanilla stable kernel to the same result.
> 
> Should I file a Red Hat bug ?

Not yet.

> Manually change IRQs, what do you think?

I need the version of the last known working Fedora 17 kernel or
your Fedora 18 install date if you can't retrieve it.

A complete dmesg and the content of /proc/interrupts will be welcome.

Thanks.

-- 
Ueimor
