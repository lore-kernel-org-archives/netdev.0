From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Fri, 27 Apr 2007 13:03:24 +0100
Message-ID: <16049.1177675404@redhat.com>
References: <20070426.202037.94552269.davem@davemloft.net>  <20070426.161522.76328746.davem@davemloft.net> <20070426.200809.04441500.davem@davemloft.net> <20070426.201213.85816532.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681AbXD0MDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 08:03:30 -0400
In-Reply-To: <20070426.202037.94552269.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>     net/rxrpc/ar-input.c:171: warning: passing argument 2 of $,1rx(B__test_and_set_bit$,1ry(B from incompatible pointer type
>     net/rxrpc/ar-input.c:180: warning: passing argument 2 of $,1rx(B__clear_bit$,1ry(B from incompatible pointer type
>     net/rxrpc/ar-input.c:218: warning: passing argument 2 of $,1rx(B__clear_bit$,1ry(B from incompatible pointer type

Acked-By: David Howells <dhowells@redhat.com>
