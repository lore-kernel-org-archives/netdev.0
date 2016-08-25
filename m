From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: md5: add LINUX_MIB_TCPMD5FAILURE counter
Date: Thu, 25 Aug 2016 16:43:37 -0700 (PDT)
Message-ID: <20160825.164337.723353698566372132.davem@redhat.com>
References: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
        julieng@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932973AbcHYXni (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:43:38 -0400
In-Reply-To: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2016 09:01:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Adds SNMP counter for drops caused by MD5 mismatches.
> 
> The current syslog might help, but a counter is more precise and helps
> monitoring.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
