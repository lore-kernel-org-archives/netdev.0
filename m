From: David Miller <davem@davemloft.net>
Subject: Re: [NEIGH]: Combine neighbour cleanup and release
Date: Wed, 08 Aug 2007 23:13:38 -0700 (PDT)
Message-ID: <20070808.231338.31234449.davem@davemloft.net>
References: <20070731211206.GH9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933888AbXHIGNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 02:13:43 -0400
In-Reply-To: <20070731211206.GH9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 31 Jul 2007 23:12:06 +0200

> Introduces neigh_cleanup_and_release() to be used after a
> neighbour has been removed from its neighbour table. Serves
> as preparation to add event notifications.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-2.6.24, thanks Thomas.
