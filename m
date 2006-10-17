From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 7/13] [RFC] [IPV6] Move source address selection into
 route lookup.
Date: Tue, 17 Oct 2006 17:52:31 +0900 (JST)
Message-ID: <20061017.175231.45194288.yoshfuji@linux-ipv6.org>
References: <4534201D.7070002@tcs.hut.fi>
	<20061016.222223.26532234.davem@davemloft.net>
	<45348DD4.4000600@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vnuorval@tcs.hut.fi, tgraf@suug.ch,
	kim.nordlund@nokia.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41741 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1423175AbWJQIuB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 04:50:01 -0400
To: jean-mickael.guerin@6wind.com
In-Reply-To: <45348DD4.4000600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <45348DD4.4000600@6wind.com> (at Tue, 17 Oct 2006 10:01:24 +0200), Jean-Mickael Guerin <jean-mickael.guerin@6wind.com> says:

> > Although this conversion is very clean and the next patch
> > is very logic, I'm going to hold on all patches from 7 onward
> > so there is some time for some discussion of the RFC'ness
> > of them :-)
> >
> With regard to RFC'ness, passing self tests TAHI "Ready Logo 2" with 
> SUBTREE
> turned on could be a valuable feedback.

Have you done it?

We've been trying to pass that, but we failed to compile;
we probably used wrong tree...

--yoshfuji
