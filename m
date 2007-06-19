From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_RXRPC: Return the number of bytes buffered in
 rxrpc_send_data()
Date: Mon, 18 Jun 2007 23:30:58 -0700 (PDT)
Message-ID: <20070618.233058.03094051.davem@davemloft.net>
References: <20070618115236.23639.71608.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754497AbXFSGak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 02:30:40 -0400
In-Reply-To: <20070618115236.23639.71608.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 18 Jun 2007 12:52:36 +0100

> Return the number of bytes buffered in rxrpc_send_data().
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Patch applied, thanks a lot David.
