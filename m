From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/6] Gigaset driver port to CAPI
Date: Mon, 24 Aug 2009 16:58:23 -0700 (PDT)
Message-ID: <20090824.165823.252820713.davem@davemloft.net>
References: <20090821-patch-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hjlipp@web.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753781AbZHXX6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 19:58:10 -0400
In-Reply-To: <20090821-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Fri, 21 Aug 2009 19:21:34 +0200 (CEST)

> the following set of six patches adds a configuration option to the
> Gigaset driver to interface to Kernel CAPI instead of the old
> ISDN4Linux subsystem. Although my unit test are not quite done yet
> I would appreciate comments.

>From my nieve perspective these changes look good, I hope
the ISDN folks look at them soon :-)
