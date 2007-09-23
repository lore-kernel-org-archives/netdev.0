From: Alan Cox <alan@redhat.com>
Subject: Re: bind and O_NONBLOCK
Date: Sun, 23 Sep 2007 16:43:52 -0400
Message-ID: <20070923204352.GA11596@devserv.devel.redhat.com>
References: <46F540F2.1090109@redhat.com> <20070922165938.GA11234@2ka.mipt.ru> <46F54CA5.8020200@redhat.com> <20070922.225818.74741259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drepper@redhat.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	alan@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935AbXIWUoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2007 16:44:12 -0400
Content-Disposition: inline
In-Reply-To: <20070922.225818.74741259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 22, 2007 at 10:58:18PM -0700, David Miller wrote:
> From: Ulrich Drepper <drepper@redhat.com>
> Date: Sat, 22 Sep 2007 10:11:01 -0700
> 
> > There was no public mail.  I asked RH engineering for proposals for
> > changes to the POSIX spec and Alan replied.
> 
> Please do not discuss such proposals only privately, especially when
> the ramifications affect the entire community.
> 
> It is important the things get hashed out on a public forum where
> all networking developers can add their insight into the problem.

It was - about six years ago while netbeui/netbios merging was being
discussed. It got tagged then and finally ended up here.
