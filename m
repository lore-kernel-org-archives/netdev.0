From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 2/2] [AF_IUCV/IUCV] : Add missing section annotations
Date: Sat, 5 May 2007 13:30:36 +0200
Message-ID: <20070505113036.GA13660@osiris.boeblingen.de.ibm.com>
References: <20070428.230626.79066898.davem@davemloft.net> <20070504094652.GA22917@de.ibm.com> <20070504095238.GB32153@de.ibm.com> <20070504.122419.28789261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fpavlic@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:43516 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564AbXEEQQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 12:16:48 -0400
Content-Disposition: inline
In-Reply-To: <20070504.122419.28789261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 12:24:19PM -0700, David Miller wrote:
> From: Frank Pavlic <fpavlic@de.ibm.com>
> Date: Fri, 4 May 2007 11:52:38 +0200
> 
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > Add missing section annotations and found and fixed some
> > Coding Style issues.
> > 
> > Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> 
> Applied, although I find it amusing that the changelog
> header talks about section annotations (plural!) but
> that is one line of the patch, whereas %99 of the patch
> is coding style cleanups.

Actually it contained the breathtaking number of 3 section
annotations, so that only 95% of the patch is coding style
cleanups ;)
Apparantly Frank merged two patches and took the one line
patch description of the first one.
