From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Thu, 18 Jul 2013 14:21:00 -0400
Message-ID: <20130718182100.GA10853@d2.synalogic.ca>
References: <20130716025954.GC26761@windriver.com>
 <1374006725.12825.112.camel@envy.home>
 <51E6B5BE.6050505@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f52.google.com ([209.85.128.52]:58553 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619Ab3GRSVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 14:21:04 -0400
Received: by mail-qe0-f52.google.com with SMTP id i11so1964978qej.39
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 11:21:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <51E6B5BE.6050505@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/07/17 11:18, Paul Gortmaker wrote:
> On 13-07-16 04:32 PM, Darren Hart wrote:
> >>
> >>    Aside from subsystems like that mentioned above, all network related linux
> >>    development (i.e. RFC, review, comments, etc) takes place on netdev.
> >>
> > 
> > 
> > Should LKML be Cc'd? I assume so...
> 
> No, not unless there is a good reason to do so.
> 

That advice would run counter to what's in
Documentation/SubmittingPatches:

  6) Select your CC (e-mail carbon copy) list.

  Unless you have a reason NOT to do so, CC linux-kernel@vger.kernel.org.

Also, get-maintainers includes lkml all the time.
