From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_RXRPC: Add a missing goto
Date: Fri, 07 Dec 2007 04:31:58 -0800 (PST)
Message-ID: <20071207.043158.127260457.davem@davemloft.net>
References: <20071207112355.12996.56012.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49166
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750997AbXLGMb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 07:31:59 -0500
In-Reply-To: <20071207112355.12996.56012.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 07 Dec 2007 11:23:55 +0000

> Add a missing goto to error handling in the RXKAD security module for AF_RXRPC.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
