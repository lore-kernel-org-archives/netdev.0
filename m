From: Olaf Kirch <okir@lst.de>
Subject: Re: Gentle Guide to the Network Stack
Date: Thu, 19 Jun 2008 13:30:56 +0200
Message-ID: <200806191330.56556.okir@lst.de>
References: <200806171105.23069.okir@lst.de> <d0383f90806190401n2c54bc5cl4e72dd65f6c64517@mail.gmail.com> <20080619.041146.08784493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:35721 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116AbYFSLbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 07:31:06 -0400
Received: from brummo (p4FD8EAF1.dip.t-dialin.net [79.216.234.241])
	(authenticated bits=0)
	by verein.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id m5JBUsNW008268
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 13:30:55 +0200
In-Reply-To: <20080619.041146.08784493.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 June 2008 13:11:46 David Miller wrote:
> > I grepped for:
> > struct sockalloc and  struct sock_alloc under the kernel tree (git 2.6
> > netdev tree)
> > and could not find such a thing.
> 
> He meant "struct socket_alloc"

Oops, you're right!

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
