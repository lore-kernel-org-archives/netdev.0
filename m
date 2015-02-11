From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Wed, 11 Feb 2015 12:23:55 +0100
Message-ID: <2609782.Mryft1leMQ@storm>
References: <1719052.SGOfRAJhfQ@storm> <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com> <1421333953.2632.22.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:45256 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbBKLX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 06:23:59 -0500
In-Reply-To: <1421333953.2632.22.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

On Thursday, 15. January 2015 06:59:13 Jeff Kirsher wrote:
> > Sure, you basically reverted my patch.
> > 
> > You are not the first to report a problem caused by this patch.
> > 
> > This patch is known to have uncovered some driver bugs.
> > 
> > We are not going to revert it. We are going to fix the real bugs.
> > 
> > Thanks
> 
> Agreed, we are looking into issue Thomas.

any news from the Intel labs what might be going on here?

We started seeing those hangs on "MSI B85M ECO" boards, too,
though it's way more sporadic there.

Thanks,
Thomas
