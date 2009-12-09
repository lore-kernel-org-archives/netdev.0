From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: don't enable any debugging output by default
Date: Tue, 08 Dec 2009 20:30:53 -0800 (PST)
Message-ID: <20091208.203053.170121191.davem@davemloft.net>
References: <20091205175219.4298A400D9@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755590AbZLIEar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:30:47 -0500
In-Reply-To: <20091205175219.4298A400D9@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat,  5 Dec 2009 18:52:19 +0100 (CET)

> When built with debugging support, the Gigaset driver enabled some
> debugging messages by default. Change the default to "all off".
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
