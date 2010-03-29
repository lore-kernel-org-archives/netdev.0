From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: CVE-2009-4537
Date: Sun, 28 Mar 2010 20:50:46 -0400
Message-ID: <20100329005046.GA2157@localhost.localdomain>
References: <20100327142100.38d21565.michael.s.gilbert@gmail.com>
 <20100327.103407.260084965.davem@davemloft.net>
 <20100327.103600.246539458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael.s.gilbert@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52430 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab0C2Au5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 20:50:57 -0400
Content-Disposition: inline
In-Reply-To: <20100327.103600.246539458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 27, 2010 at 10:36:00AM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 27 Mar 2010 10:34:07 -0700 (PDT)
> 
> > From: Michael Gilbert <michael.s.gilbert@gmail.com>
> > Date: Sat, 27 Mar 2010 14:21:00 -0400
> > 
> >> Hi,
> >> 
> >> CVE-2009-4537 has been disclosed without any upstream activity for a
> >> while now. Discussion about the issue dried up in January [0], and a
> >> patch had been proposed [1], but no arguments were seen either for or
> >> against it. Note that redhat has already shipped that in their various
> >> kernel security updates.  Would it make sense to merge those changes
> >> officially?
> > 
> > A different version of the fix went into the tree.
> 
> Ignore me, that was a fix for a different problem.
> 
> I was waiting for Francois to come up with a cleaner fix
> but he stopped working on it, so yes I should put in
> the fix you mention or something similar.
> 
> Neil, can you formally submit a version of the r8169
> CVE for upstream?
> 
> Thanks.
> 
Absolutley, I'll review the CVE text and my origional patch tomorrow morning,
and submit the official patch tomorrow afternoon.

Thanks!
Neil

