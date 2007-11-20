From: Ben Dooks <ben@fluff.org>
Subject: Re: [patch 00/22] DM9000 updates for 2.6.25
Date: Tue, 20 Nov 2007 10:13:51 +0000
Message-ID: <20071120101351.GB3244@fluff.org.uk>
References: <20071119203910.687238131@fluff.org> <20071119150431.43b09d0c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	vince@simtec.co.uk
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:49471 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751898AbXKTKO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 05:14:26 -0500
Content-Disposition: inline
In-Reply-To: <20071119150431.43b09d0c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 03:04:31PM -0800, Stephen Hemminger wrote:
> On Mon, 19 Nov 2007 20:39:10 +0000
> Ben Dooks <ben-linux@fluff.org> wrote:
> 
> > This is my current proposed patch series to the DM9000
> > driver for both general cleanups, support for ethtool
> > and to make the code better.
> > 
> 
> You could also change all instances of dev->priv with netdev_priv(dev).

Ok, will add that to the patch set.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
