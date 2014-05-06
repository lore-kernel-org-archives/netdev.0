From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 10:21:06 -0700
Message-ID: <20140506172106.GB20776@cloud>
References: <20140506155703.GA20391@cloud>
 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140506164546.GB20536@cloud>
 <20140506.131752.740569380523989782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:60139 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbaEFRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:21:10 -0400
Content-Disposition: inline
In-Reply-To: <20140506.131752.740569380523989782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 01:17:52PM -0400, David Miller wrote:
> From: josh@joshtriplett.org
> Date: Tue, 6 May 2014 09:45:46 -0700
> 
> > The kernel can do the same.  Consider the idea of analyzing a set of
> > userspace programs, determining what kernel functionality they do and
> > don't need, feeding that information into the kernel build process, and
> > automatically dropping unused bits of the kernel.
> 
> Please make sure I'm not on the list of people who see reports for
> bugs reported in that setup.
> 
> Thanks :-)

Fine by me.  Just please allow such a setup to exist. :)

- Josh Triplett
