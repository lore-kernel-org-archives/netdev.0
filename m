From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/4] atl1: Header files for Attansic L1 driver
Date: Thu, 11 Jan 2007 09:44:16 -0800
Message-ID: <20070111094416.0dc4b316@localhost>
References: <20070111004137.GC2624@osprey.hogchain.net>
	<20070111092704.GB3141@infradead.org>
	<20070111165330.GA6191@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, jeff@garzik.org,
	csnook@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49857 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbXAKRpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 12:45:20 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20070111165330.GA6191@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Jan 2007 10:53:30 -0600
Jay Cliburn <jacliburn@bellsouth.net> wrote:

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
> 
> Jay

Comments should not insult the reader by stating the obvious.
