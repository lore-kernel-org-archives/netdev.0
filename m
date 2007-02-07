From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Wed, 7 Feb 2007 11:31:44 +0100
Message-ID: <20070207103144.GB14727@de.ibm.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:60123 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161160AbXBGKeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 05:34:02 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l17AYfRg027034
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 05:34:41 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l17AY0Ju266804
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 05:34:00 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l17AY0GZ019653
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 05:34:00 -0500
Content-Disposition: inline
In-Reply-To: <20070206.144106.39659974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 06, 2007 at 02:41:06PM -0800, David Miller wrote:
> From: Frank Pavlic <fpavlic@de.ibm.com>
> Date: Fri, 2 Feb 2007 13:05:28 +0100
> 
> > The patch set consists of following patches:
> > 
> > [1/7] [S390]: Rewrite of the IUCV base code, part 1
> > [2/7] [S390]: Rewrite of the IUCV base code, part 2
> > [3/7] [S390]: Adapt monreader driver to new IUCV API
> > [4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
> > [5/7] [S390]: Adapt netiucv driver to new IUCV API
> > [6/7] [S390]: Adapt special message interface to new IUCV API
> > [7/7] [S390]: Add AF_IUCV socket support
> 
> I have no fundamental objections to this, although I think
> I'll end up needing something similar on Niagara at some
> point :-)
> 
> The list ate the first patch due to it's size.  Could you
> email me a copy privately so can integrate all of your work
> into my net-2.6.21 tree?
> 
> Thanks.
> -
Dave,
Really good news for me, I just have started to split the first patch :-)
Thank you 
I send you a copy privately...

Frank
