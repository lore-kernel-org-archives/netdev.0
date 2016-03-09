From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: Replace all unsigned with unsigned int
Date: Wed, 09 Mar 2016 23:25:04 +0000
Message-ID: <19318.1457565904@warthog.procyon.org.uk>
References: <20160309232256.18612.76458.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964980AbcCIXZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 18:25:07 -0500
In-Reply-To: <20160309232256.18612.76458.stgit@warthog.procyon.org.uk>
Content-ID: <19317.1457565904.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> Replace all "unsigned" types with "unsigned int" types.
> 
> Reported-by: David Miller <davem@davemloft.net>
> Signed-off-by: David Howells <dhowells@redhat.com>

This is aimed at net-next.

David
