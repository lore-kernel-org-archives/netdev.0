From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #3]
Date: Tue, 20 Mar 2007 21:12:22 +0000
Message-ID: <20070320211222.62dae706@lxorguk.ukuu.org.uk>
References: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:52884 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932960AbXCTUJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 16:09:20 -0400
In-Reply-To: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  (*) SOCK_RPC has been removed.  AF_RXRPC sockets now simply ignore the "type"
>      argument to socket().

This is also incorrect

NAK

