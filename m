From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 based device
Date: Fri, 3 Feb 2012 14:26:11 +0100
Message-ID: <20120203132611.GA21693@electric-eye.fr.zoreil.com>
References: <CAOkhdCf-emWHJ0rB9GtC3MnX6oj3jgRAbYJU+q65GzMUdXmd-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Hawkins <adhawkins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45608 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109Ab2BCNhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 08:37:33 -0500
Content-Disposition: inline
In-Reply-To: <CAOkhdCf-emWHJ0rB9GtC3MnX6oj3jgRAbYJU+q65GzMUdXmd-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Hawkins <adhawkins@gmail.com> :
[...]
> Secondly, I realise that the kernel I'm using here is quite old.
> However, this is the kernel provided by the version of Openfiler I'm
> using, so updating isn't a simple matter.

Which kernel version is it and does an "XID" line appear for the r8169
driver in the kernel log ?

[...]
> Can anyone offer any advice on getting this card to work?

In the end there may be only two paths left : upgrade the kernel or
backport the driver.

It could help if some openfiler developer was available, at the very
least to retrieve an adequate kernel build tree if backporting is the
only option.

-- 
Ueimor
