From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Fri, 16 Mar 2007 14:23:13 +0000
Message-ID: <25571.1174054993@redhat.com>
References: <20070316151305.04cbc352@lxorguk.ukuu.org.uk>  <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965154AbXCPOX3@vger.kernel.org>
In-Reply-To: <20070316151305.04cbc352@lxorguk.ukuu.org.uk> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> If your messages are datagrams and unreliable -> SOCK_DGRAM

Nope.

> If your messages are datagrams and reliable -> SOCK_RDM

Nope.

> If your messages are datagrams, reliable and ordered -> SOCK_SEQPACKET

Nope.

> If your messages are streams of bits, reliable and ordered -> SOCK_STREAM

Nope.

David
