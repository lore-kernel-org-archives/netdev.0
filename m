From: Milan Kocian <milon@wq.cz>
Subject: Re: [RFT] sky2: 32 bit DMA quirk
Date: Fri, 9 Dec 2011 01:11:44 +0100
Message-ID: <20111209001144.GB13613@ntm.wq.cz>
References: <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
 <20111122094234.GA28500@ntm.wq.cz>
 <20111126161513.GA5299@ntm.wq.cz>
 <20111126170331.744025f1@s6510.linuxnetplumber.net>
 <20111205124725.GA19385@ntm.wq.cz>
 <20111205081611.52ec0664@nehalam.linuxnetplumber.net>
 <20111206095919.GA6726@ntm.wq.cz>
 <20111207150205.3fad9290@nehalam.linuxnetplumber.net>
 <20111208195833.GA13613@ntm.wq.cz>
 <20111208152614.37a8379b@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:34014 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751156Ab1LIALy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:11:54 -0500
Content-Disposition: inline
In-Reply-To: <20111208152614.37a8379b@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2011 at 03:26:14PM -0800, Stephen Hemminger wrote:
> On Thu, 8 Dec 2011 20:58:33 +0100
> Milan Kocian <milon@wq.cz> wrote:
> 
> > Hello Stephen,
> > 
> > On Wed, Dec 07, 2011 at 03:02:05PM -0800, Stephen Hemminger wrote:
> > > This a patch to force 32 bit DMA. Not sure if the DMI values
> > > are right for the Gigabyte motherboard with the problem.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > 
> > 
> > Unfortunately it didn't help. I tried parameter
> > only_32bit_dma=1 alone and then with parameter disable_msi=1
> > with the same result.
> 
> Thanks for trying. Looks like not worth bothering investigating further.
> 
 
Yes, I agree. Many thanks for your time Stephen.

-- 
Milan Kocian
