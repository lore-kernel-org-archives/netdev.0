From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute2 skbedit: Add support to mark packets
Date: Thu, 4 Mar 2010 08:48:29 -0800
Message-ID: <20100304084829.22a80ace@nehalam>
References: <1259847168.3766.40.camel@bigi>
	<20100303163638.09520577@nehalam>
	<1267671091.4821.27.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842Ab0CDQsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 11:48:46 -0500
In-Reply-To: <1267671091.4821.27.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Mar 2010 21:51:31 -0500
jamal <hadi@cyberus.ca> wrote:

> You applied 2/2 but not 1/2.
> 
> cheers,
> jamal
> On Wed, 2010-03-03 at 16:36 -0800, Stephen Hemminger wrote:
> > On Thu, 03 Dec 2009 08:32:48 -0500
> > jamal <hadi@cyberus.ca> wrote:
> > 
> > > I did this originally because i was getting too many support
> > > questions on ipt with mark. It still makes sense since skbedit
> > > seems to be the mother action of skb metadata (should probably
> > > have been called skbmeta).
> > > 
> > > cheers,
> > > jamal
> > 

The first was the help message text, and that was already there.
Or was there some other bit.
