From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Wed, 1 May 2013 16:28:07 -0500
Message-ID: <20130501212803.GA3342@gmail.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f177.google.com ([209.85.213.177]:36292 "EHLO
	mail-ye0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761685Ab3EAV2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 17:28:12 -0400
Received: by mail-ye0-f177.google.com with SMTP id r11so348252yen.8
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 14:28:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130501121502.GA5456@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 02:15:02PM +0200, Francois Romieu wrote:
> Lance Lassetter <lancelassetter@gmail.com> :
> [...]
> > Any luck with this ?
> 
> This is not the usual AMD iommu + realtek NIC problem.
> 
> This is not the usual "I upgraded from 2.6 and my Realtek NIC stopped working".
> 
> This is not "recent Realtek NIC support is wet".
> 
> This is not an "old Realtek PCI NIC stopped working" only problem.
> 
> This is an AMD box.
> 
> May I assume that you used an up-to-date Fedora 17 before migrating to
> Fedora 18 when it was published ?
> 
> -- 
> Ueimor

Ueimor,

Yes, it was an up to date Fedora 17.  I know this is probably redundant but I also tried Realtek firmware from a Debian Sid box onto the Fedora 18 using testing repos with vanilla stable kernel to the same result.

Should I file a Red Hat bug?  Manually change IRQs, what do you think?

Regards,

Lance
