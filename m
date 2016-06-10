From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/2] rxrpc: Limit the listening backlog
Date: Fri, 10 Jun 2016 14:40:28 +0100
Message-ID: <17686.1465566028@warthog.procyon.org.uk>
References: <146556584336.17266.3323627198404452525.stgit@warthog.procyon.org.uk> <146556583626.17266.7208552374581913605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753350AbcFJNka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 09:40:30 -0400
In-Reply-To: <146556584336.17266.3323627198404452525.stgit@warthog.procyon.org.uk>
Content-ID: <17685.1465566028.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> +		else if (backlog > max)
> +			break;

Oops.  Please ignore this version of the patch - I forgot to commit a change
to it before posting.

David
