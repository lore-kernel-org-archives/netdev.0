From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] ipv6: mld: rename mc_maxdelay into mc_uri
Date: Wed, 24 Sep 2014 22:34:57 +0200
Message-ID: <1411590897.2486568.171399997.0B5FD281@webmail.messagingengine.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
 <1411455828-5196-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43175 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbaIXUe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:34:58 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 7522020AB8
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 16:34:57 -0400 (EDT)
In-Reply-To: <1411455828-5196-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014, at 09:03, Daniel Borkmann wrote:
> The name mc_maxdelay is quite confusing as it actually denotes the
> unsolicited report interval. Since we have query response interval
> named as mc_qri, name unsolicited report interval analogously as
> mc_uri. Note that both are not the same!
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
