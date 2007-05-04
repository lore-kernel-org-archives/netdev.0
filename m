From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Date: Fri, 04 May 2007 12:54:42 -0700 (PDT)
Message-ID: <20070504.125442.70218284.davem@davemloft.net>
References: <1178293081.24217.46.camel@twins>
	<1178294379.7997.26.camel@imap.mvista.com>
	<170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwalker@mvista.com, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch,
	James.Bottomley@steeleye.com, michaelc@cs.wisc.edu,
	akpm@linux-foundation.org, phillips@google.com
To: snitzer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423101AbXEDTy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:54:56 -0400
In-Reply-To: <170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mike Snitzer" <snitzer@gmail.com>
Date: Fri, 4 May 2007 14:09:40 -0400

> These suggestions conflict in the case of a large patchset: the second
> can't be met if you honor the first (more important suggestion IMHO).
> Unless you leave something out... and I can't see the value in leaving
> out the auxiliary consumers of the core changes.

They do not conflict.

If you say you're setting up infrastructure for a well defined
purpose, then each and every one of the patches can all stand on their
own just fine.  You can even post them one at a time and the review
process would work just fine.

