From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Thu, 08 Mar 2007 22:54:32 +0000
Message-ID: <17617.1173394472@redhat.com>
References: <20070308224806.17456.13944.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030847AbXCHWyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 17:54:54 -0500
In-Reply-To: <20070308224806.17456.13944.stgit@warthog.cambridge.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> These patches together supply secure client-side RxRPC connectivity as a Linux
> kernel socket family.  Only the transport/session side is supplied - the
> presentation side (marshalling the data) is left to the client.

The patches can also be downloaded from:

	http://people.redhat.com/~dhowells/rxrpc/01-crypto-kernel-buff.diff
	http://people.redhat.com/~dhowells/rxrpc/02-move-skb-generic.diff
	http://people.redhat.com/~dhowells/rxrpc/03-timers.diff
	http://people.redhat.com/~dhowells/rxrpc/04-keys.diff
	http://people.redhat.com/~dhowells/rxrpc/05-af_rxrpc.diff

David
