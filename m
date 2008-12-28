From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow dependancies of FDDI & Tokenring to be modular.
Date: Sat, 27 Dec 2008 20:44:04 -0800 (PST)
Message-ID: <20081227.204404.75308850.davem@davemloft.net>
References: <20081226215251.GA5136@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754536AbYL1EoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 23:44:01 -0500
In-Reply-To: <20081226215251.GA5136@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Fri, 26 Dec 2008 16:52:51 -0500

> I noticed it isn't possible to build token ring & fddi drivers
> without causing LLC, and a bunch of other things to be forced
> built-in.  For distro kernels, this means carrying a chunk of
> code in the vmlinuz, even if the user doesn't use those protocols.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Looks good.

Applied, thanks Dave.
