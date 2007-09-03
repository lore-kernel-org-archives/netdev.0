From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Mon, 3 Sep 2007 12:09:08 -0400
Message-ID: <9e4733910709030909j50710faaw96c95cb369a810b3@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Domen Puncer" <domen@coderock.org>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:41238 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbXICQJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 12:09:12 -0400
Received: by nz-out-0506.google.com with SMTP id s18so832442nze
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2007 09:09:10 -0700 (PDT)
In-Reply-To: <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/3/07, Grant Likely <grant.likely@secretlab.ca> wrote:
> On 9/2/07, Domen Puncer <domen@coderock.org> wrote:
> > Hi!
> >
> > new in this version:
> > - fixed stuff that was commented on.
> > - added 7-wire support (compile at least, if someone has the hardware,
> >         please test!)
> > - ethtool support
>
> Thanks for this work Domen, comments below...
>
> This is a large patch, and it should be broken up into logical
> changes.  ie. split into dts changes, bestcomm changes, fec driver and
> mdio driver.  Easier to review that way.  The bestcomm and dts changes
> don't need to go to the netdev list.

A similar patch that is already broken up is available for Efika.
http://dev.gentoo.org/~nixnut/efika/efika-patches-2.6.22.tar.bz2

-- 
Jon Smirl
jonsmirl@gmail.com
