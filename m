From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: avoid a full fib lookup when rp_filter is
 disabled.
Date: Wed, 20 Sep 2017 18:37:10 +0200
Message-ID: <1505925430.28140.11.camel@redhat.com>
References: <597db26b5e57eb89d2ff27454cce997fa6c0f5aa.1505924560.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37058 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751024AbdITQhN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:37:13 -0400
In-Reply-To: <597db26b5e57eb89d2ff27454cce997fa6c0f5aa.1505924560.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dumb me and dumb my scripts. 

This is actually a v2, v1 was at:

https://patchwork.ozlabs.org/project/netdev/list/?series=3835

David, please let me know if you prefer I'll repost with a more
appropriate subject line.

Sorry for the noise,

Paolo
