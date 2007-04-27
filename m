From: Bill Fink <billfink@mindspring.com>
Subject: netdev file size restrictions???  Was: Re: [PATCH 04/14] AF_RXRPC:
 Provide secure RxRPC sockets for ...
Date: Fri, 27 Apr 2007 03:52:20 -0400
Message-ID: <20070427035220.643283e0.billfink@mindspring.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
	<20070426195436.24531.34654.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:51863 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755455AbXD0HwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 03:52:21 -0400
In-Reply-To: <20070426195436.24531.34654.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Apr 2007 20:54:36 +0100, David Howells wrote:

> Provide AF_RXRPC sockets that can be used to talk to AFS servers, or serve
> answers to AFS clients.  KerberosIV security is fully supported.  The patches
> and some example test programs can be found in:
> 
> 	http://people.redhat.com/~dhowells/rxrpc/
> 
> This will eventually replace the old implementation of kernel-only RxRPC
> currently resident in net/rxrpc/.
> 
> The following documentation is from Documentation/networking/rxrpc.txt:
> 
> 			    ======================
> 			    RxRPC NETWORK PROTOCOL
> 			    ======================
...

Did the file size restrictions for netdev somehow get lifted?
I just received this e-mail that my mail client says is 339.3KB
(and a few others that are over 100KB (some well over)).

						-Bill
