From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Thu, 30 Jul 2009 18:53:16 -0700 (PDT)
Message-ID: <20090730.185316.110755605.davem@davemloft.net>
References: <20090730.142345.148651785.davem@davemloft.net>
	<20090730.142554.103113174.davem@davemloft.net>
	<20090731011130.GA16769@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752337AbZGaBxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:53:09 -0400
In-Reply-To: <20090731011130.GA16769@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 30 Jul 2009 21:11:30 -0400

> Ok, version 2. I'm not sure exactly what went wrong, but I definately had it
> built and running.

As I said in my other email, the original patch does build and it
probably runs too, it's just the warnings that you definitely didn't
notice in the build at all.

I've apply this new version, thanks.
