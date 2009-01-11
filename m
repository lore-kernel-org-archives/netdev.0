From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 23:36:59 -0800 (PST)
Message-ID: <20090110.233659.144845240.davem@davemloft.net>
References: <49688120.9000507@katalix.com>
	<20090110111359.GA29349@localhost>
	<20090110125444.GB29349@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbZAKHhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:37:00 -0500
In-Reply-To: <20090110125444.GB29349@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 10 Jan 2009 15:54:44 +0300

> Maybe you have some other commits which are not propogated
> to net-next-2.6 yet?

net-next-2.6 is a throw away tree that is a clone of essentially
2.6.28 after Linus first took the net-next-2.6

It has not been updated for weeks, all development has been
occurring in the net-2.6 tree
