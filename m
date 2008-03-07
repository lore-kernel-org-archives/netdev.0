From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Thu, 6 Mar 2008 18:33:35 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803061833140.29585@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com>
 <47CC6F30.50802@cs.helsinki.fi> <20080305002821.GD1510@wotan.suse.de>
 <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com>
 <20080306024904.GA27150@wotan.suse.de> <Pine.LNX.4.64.0803061451230.16212@schroedinger.engr.sgi.com>
 <20080307020443.GA21185@wotan.suse.de> <Pine.LNX.4.64.0803061816430.28976@schroedinger.engr.sgi.com>
 <20080307022537.GC21185@wotan.suse.de> <Pine.LNX.4.64.0803061827040.29527@schroedinger.engr.sgi.com>
 <20080307023315.GE21185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:55842 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761686AbYCGCdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 21:33:53 -0500
In-Reply-To: <20080307023315.GE21185@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Mar 2008, Nick Piggin wrote:

> On Thu, Mar 06, 2008 at 06:27:12PM -0800, Christoph Lameter wrote:
> > On Fri, 7 Mar 2008, Nick Piggin wrote:
> > 
> > > > Is that really a noteworthy effect?
> > > 
> > > Yes.
> > 
> > Numbers?
> 
> Uhh... big number > small number

Can you quantify the effect?
