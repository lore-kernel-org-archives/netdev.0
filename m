From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Wed, 1 May 2013 21:23:31 -0500
Message-ID: <20130502022330.GB30099@gmail.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
 <20130501223155.GA15261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f171.google.com ([209.85.213.171]:37088 "EHLO
	mail-ye0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807Ab3EBCXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 22:23:35 -0400
Received: by mail-ye0-f171.google.com with SMTP id l12so26610yen.16
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 19:23:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130501223155.GA15261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 02, 2013 at 12:31:55AM +0200, Francois Romieu wrote:
> Lance Lassetter <lancelassetter@gmail.com> :
> [...]
> > Yes, it was an up to date Fedora 17.  I know this is probably redundant but
> > I also tried Realtek firmware from a Debian Sid box onto the Fedora 18
> > using testing repos with vanilla stable kernel to the same result.
> > 
> > Should I file a Red Hat bug ?
> 
> Not yet.
> 
> > Manually change IRQs, what do you think?
> 
> I need the version of the last known working Fedora 17 kernel or
> your Fedora 18 install date if you can't retrieve it.
> 
> A complete dmesg and the content of /proc/interrupts will be welcome.
> 
> Thanks.
> 
> -- 
> Ueimor

The initial FC18 Alpha kernel was 3.6 RC2 Fedora Core kernel.

I've just started using Fedora vanilla repos for kernel just recently; although they are not pure vanilla and do contain a minimal patchset from Fedora.

I've never compiled my own kernel on the machine with the r8169 issue.

Thanks,

Lance
