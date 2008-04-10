From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 0/2] Labeled networking patches for 2.6.26
Date: Thu, 10 Apr 2008 18:12:36 -0400
Message-ID: <200804101812.36542.paul.moore@hp.com>
References: <20080409204936.26774.55254.stgit@flek.lan> <200804101725.59604.paul.moore@hp.com> <Xine.LNX.4.64.0804110802140.1313@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:43620 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168AbYDJWMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 18:12:51 -0400
In-Reply-To: <Xine.LNX.4.64.0804110802140.1313@us.intercode.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 10 April 2008 6:04:32 pm James Morris wrote:
> On Thu, 10 Apr 2008, Paul Moore wrote:
> > Just a quick follow-up on testing, I've run this for a few hours on
> > two Fedora systems with both labeled and unlabeled IPsec in use
> > with SAs rekeying every 5 minutes and didn't notice anything evil.
> >
> > At this point I'd strip the "RFC" from the patchset and ask that
> > they be considered for inclusion in 2.6.26 assuming there are no
> > objections.
>
> I suggest pushing them via DaveM's tree, unless they depend on
> anything in my tree.

Okay.  It sounds like DaveM is working through a backlog right now, if I 
don't see them in his tree by next week I'll resubmit them.

Thanks.

-- 
paul moore
linux @ hp
