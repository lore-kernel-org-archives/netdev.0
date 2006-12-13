From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.17.13 2/2] LARTC: trace control for netem:
 kernelspace
Date: Wed, 13 Dec 2006 10:16:56 -0800
Message-ID: <20061213101656.6068c793@dxpl.pdx.osdl.net>
References: <4514DC9A.2000505@tik.ee.ethz.ch>
	<20060925132800.09856e10@dxpl.pdx.osdl.net>
	<45198AF5.9090909@tik.ee.ethz.ch>
	<20060926134531.3ec4991a@freekitty>
	<457A7F43.3020004@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56269 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932657AbWLMSep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 13:34:45 -0500
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
In-Reply-To: <457A7F43.3020004@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 09 Dec 2006 10:17:55 +0100
Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:

> Hi Stephens
> 
> I just wanted to ask you if everything went right with TCN and we will
> find it in 2.6.20 as you wrote two months ago.
> 
> Cheers
> Rainer
> 
> Stephen Hemminger wrote:
> > On Tue, 26 Sep 2006 22:17:57 +0200
> > Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:
> >
> >   
> >> Hi Stephens
> >>
> >> We merged your changes into our patch
> >> http://tcn.hypert.net/tcn_kernel_2_6_18.patch
> >> Please let us know if we should do further adoptions to our
> >> implementation and/or resubmit the adapted patch.
> >>
> >> Cheers+thanx,
> >> Rainer
> >>     
> >
> > I'll test it out, and send off to Dave for 2.6.20, 2.6.19 is so in
> > flux right now that adding more seems not like a good idea.
> >
> >
> >   
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

If I get a cleaned up version to test, I have some time to check it
before 2.6.20
