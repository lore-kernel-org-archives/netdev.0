From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Wed, 24 Sep 2014 22:36:04 +0200
Message-ID: <1411590964.2487167.171400385.46AF6606@webmail.messagingengine.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
 <1411455828-5196-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53703 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751012AbaIXUgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:36:05 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id D76592091A
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 16:36:04 -0400 (EDT)
In-Reply-To: <1411455828-5196-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014, at 09:03, Daniel Borkmann wrote:
> While reviewing the code, I found it confusing why we update the URI when
> receiving an MLDv2 query. The RFC does not mention any of this, and I
> also
> double-checked with other implementations.
>
> [...]
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
