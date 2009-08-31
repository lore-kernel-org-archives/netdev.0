From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 11:03:56 +0300
Message-ID: <200908311103.56770.denys@visp.net.lb>
References: <20090826215956.GA5148@ami.dom.local> <20090831053026.GA5005@ff.dom.local> <20090830.223239.185830289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35853 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbZHaIIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:08:25 -0400
In-Reply-To: <20090830.223239.185830289.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 August 2009 08:32:39 David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 31 Aug 2009 05:30:27 +0000
>
> > Actually, I think now, after 2.6.31, this patch might be a bit too
> > late. If people hit this problem they probably should've fixed it
> > until -next already, so let's forget about this patch until there are
> > more such reports.
>
> Ok.
>
> > Btw, I guess, Denys could submit some warnings into iproute's code
> > and/or documentation, as he proposed earlier.
>
> Yeah sounds like a good idea.
Sorry, just was busy with network overload on ramadan.
I will test now.

