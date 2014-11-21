From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Fri, 21 Nov 2014 13:59:10 +0100
Message-ID: <20141121125910.GB6031@localhost.localdomain>
References: <cover.1416562191.git.rcochran@linutronix.de>
 <00356ddec4e20d99010884c8f18cd00df4419eaf.1416562192.git.rcochran@linutronix.de>
 <1416573969.2280.39.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bruce.w.allan@intel.com, Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>, Jian Yu <jian.yu@ni.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:41241 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758326AbaKUM7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 07:59:15 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so11949592wiw.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 04:59:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416573969.2280.39.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 04:46:09AM -0800, Jeff Kirsher wrote:
> On Fri, 2014-11-21 at 10:41 +0100, Richard Cochran wrote:
> > +	/* Make sure this pin is not enabled as an ouput. */
> 
> Minor nitpick, output is mis-spelled (I can fix that up for you)

Yes please.

> Probably should have a blank line after the local variable declaration.
> Again, I can fix this up for ya.

Okay.

Thanks,
Richard
