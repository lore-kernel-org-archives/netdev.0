From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 11:43:43 +0100
Message-ID: <1150281823.3490.14.camel@localhost.localdomain>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
	 <200606131859.43695.chase.venters@clientec.com>
	 <20060613183112.B8460@openss7.org>
	 <200606131953.42002.chase.venters@clientec.com>
	 <20060614000710.C7232@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chase Venters <chase.venters@clientec.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:61373 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S932212AbWFNK1e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 06:27:34 -0400
To: bidulock@openss7.org
In-Reply-To: <20060614000710.C7232@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Mer, 2006-06-14 am 00:07 -0600, ysgrifennodd Brian F. G. Bidulock:
> I think that a policy that intentionally makes it hard for proprietary
> modules to be developed defeats the purpose of ultimate opening and merging.

It isn't "policy" its called copyright law.

> The interface currently under discussion is ultimately derived from the BSD
> socket-protocol interface, and IMHO should be EXPORT_SYMBOL instead of
> EXPORT_SYMBOL_GPL, if only because using _GPL serves no purpose here and can
> be defeated with 3 or 4 obvious (and probably existing) lines of code

You don't seem to understand copyright law either. The GPL like all
copyright licenses deals with the right to make copies and to create and
control derivative works. It's not "defeated" by four lines of code.
  I
> wrote similar wrappers for STREAMS TPI to Linux NET4 interface instead of
> using pointers directly quite a few years ago.  I doubt I was the first.

Is that a confession ;)

> There is nothing really so novel here that it deserves _GPL.

Copyright is not about novelty, you have it confused with the
theoretical (not actual) role of patents. Wrong kind of intellectual
monopoly right.

Alan

