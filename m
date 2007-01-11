From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4] atl1: Header files for Attansic L1 driver
Date: Thu, 11 Jan 2007 17:58:33 +0000
Message-ID: <20070111175833.GA15053@infradead.org>
References: <20070111004137.GC2624@osprey.hogchain.net> <20070111092704.GB3141@infradead.org> <20070111165330.GA6191@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, jeff@garzik.org,
	shemminger@osdl.org, csnook@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59639 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbXAKR7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 12:59:04 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20070111165330.GA6191@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 11, 2007 at 10:53:30AM -0600, Jay Cliburn wrote:
> On Thu, Jan 11, 2007 at 09:27:04AM +0000, Christoph Hellwig wrote:
> > On Wed, Jan 10, 2007 at 06:41:37PM -0600, Jay Cliburn wrote:
> > > +/**
> > > + * atl1.h - atl1 main header
> > 
> > Please remove these kind of comments, they get out of date far too soon
> > and don't really help anything.  (Also everywhere else in the driver)
> 
> Is your concern here with the filename portion of the comment only, or
> with the entire comment including the copyright and other material?

Only the line I quoted.  Copyright statements and similar things are
obviously fine :)
