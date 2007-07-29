From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] l2cap: don't mangle cmd.len
Date: Sun, 29 Jul 2007 00:18:37 -0700 (PDT)
Message-ID: <20070729.001837.104033253.davem@davemloft.net>
References: <E1IEPNw-0005TA-89@ZenIV.linux.org.uk>
	<1185547286.13228.18.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759051AbXG2HSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 03:18:42 -0400
In-Reply-To: <1185547286.13228.18.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri, 27 Jul 2007 16:41:26 +0200

> > Since nobody uses it after we convert it to host-endian,
> > no need to do that at all.  At that point l2cap is endian-clean.
> > 
> > Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Also applied, thanks a lot.
