From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 01/24] rxrpc: Fix processing of authenticated/encrypted jumbo packets
Date: Tue, 05 Jul 2016 20:26:38 +0100
Message-ID: <15853.1467746798@warthog.procyon.org.uk>
References: <3303be0f-af5a-282a-e7d6-bf16a4aee2e1@cogentembedded.com> <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk> <146772433840.21657.17138888082363167022.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbcGET0l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:26:41 -0400
In-Reply-To: <3303be0f-af5a-282a-e7d6-bf16a4aee2e1@cogentembedded.com>
Content-ID: <15852.1467746798.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> > When commit 0d12f8a4027d021c9cc942f09f38d28288020c5d moved to keeping the
> 
>    scripts/checkpatch.pl now enforces the common commit citing style as for
> the Fixes: tag and the patch description, you need to specify the summary too.

I've now added a "Fixes:" line for the commit, but checkpatch erroneously
complains that I'm mentioning a commit ID in the commit text.

David
