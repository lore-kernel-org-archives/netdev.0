From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 22:53:56 +0100
Message-ID: <20080326215356.GB16497@ami.dom.local>
References: <47EA7DE8.9070203@sun.com> <47EAAE9A.9050305@gmail.com> <47EAB158.3080806@sun.com> <20080326214648.GA16497@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:58132 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832AbYCZVn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 17:43:56 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1478951nfb.21
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 14:43:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080326214648.GA16497@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 10:46:48PM +0100, Jarek Poplawski wrote:
> On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
...
> > 454:      19249      93234     907186       2691          0        188    
> >       0        160   PCI-MSI-edge      eth6
> ...
> > .......
> >
> > 454:      19249     126519     907186       2691          0        188    
> >       0        160   PCI-MSI-edge      eth6
> 
> 
> Hmm... Is this before disabling or I miss something?

OOPS! I see - only not cleared. So it's OK!

Sorry,
Jarek P.
