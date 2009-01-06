From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Tue, 6 Jan 2009 21:10:28 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901062106340.26105@wrl-59.cs.helsinki.fi>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
 <20081229214101.4c4f5ac1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com>
 <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Speedster <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47377 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbZAFTKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 14:10:30 -0500
In-Reply-To: <4961ECD2.1000502@haveacry.com>
Content-ID: <Pine.LNX.4.64.0901062106342.26105@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Jan 2009, Speedster wrote:

> Herbert Xu wrote:
> > On Wed, Dec 31, 2008 at 11:22:23PM +0000, Speedster wrote:
> > > The gateway machine (whinge) runs as a KVM guest, and shares a physical
> > > host with three other guests (one Windows, two Linux). Below are the
> > > outputs of bridge topology and VLAN tagging on the physical host.
> > 
> > What driver are you using on whinge?
> > 
> > When you took the packet dumps, was it on whinge or the physical
> > host? If it was taken on whinge, can you try to take the same
> > dumps on the outgoing physical interface on the host?
> > 
> > Thanks,
> 
> I have tried both virtio and the default (8139too).

And what is the actual eth hw on the host?

> The original dumps were taken on whinge, I have attached two new dumps 
> showing the functional (2.6.24) and non-functional (2.6.27) states from 
> the host.

At least to me those didn't reveal anything new :-(.

-- 
 i.
