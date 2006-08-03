From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/6] zd1211rw: Pass more management frame types up to host
Date: Thu, 3 Aug 2006 09:32:42 -0400
Message-ID: <20060803133237.GA7079@tuxdriver.com>
References: <1154468615618-git-send-email-kune@deine-taler.de> <1154468615613-git-send-email-kune@deine-taler.de> <20060802215828.GB5084@tuxdriver.com> <20060803060905.GA1622@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:44038 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932358AbWHCNcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 09:32:53 -0400
To: netdev@vger.kernel.org, dsd@gentoo.org
Content-Disposition: inline
In-Reply-To: <20060803060905.GA1622@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 08:09:06AM +0200, Ulrich Kunitz wrote:

> Would it be acceptable if I hint on such "bridge" patches in the
> futture or should we create a clean patch sequence? The latter would
> require us to rewrite patches manually.

I was mostly just poking fun at you. :-)  Still, I suppose it wouldn't
hurt to acknowledge when a "not really a fix" patch is being included.

When the trivial "not really a fix" patch becomes a non-trivial "really
a new feature" patch, then we create a situation that may force the
feature patch and all it's dependant patches to be pushed to the next
merge window.  In that case, if the later fixes are important than
the patch sequence may need to be rewritten.

> BTW we will have a greater number of patches for 2.6.19 (around 30),
> which supports more devices and also cleans stuff. Some work is
> however still required.

That sounds great.  Please do get them in ASAP (after reasonable
testing, of course).  There was some talk at the kernel summit of
requiring all feature patches to be in the sub-maintainer trees BEFORE
Linus opens the merge window.  I'm not sure that was fully agreed upon,
but still earlier is better.

John
-- 
John W. Linville
linville@tuxdriver.com
