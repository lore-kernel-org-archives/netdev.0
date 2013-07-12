From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] tcp: account all retransmit failures
Date: Fri, 12 Jul 2013 16:16:16 -0700 (PDT)
Message-ID: <20130712.161616.1291098149600095359.davem@redhat.com>
References: <1373653984-30249-1-git-send-email-ycheng@google.com>
	<1373655354.10804.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab3GLXQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 19:16:20 -0400
In-Reply-To: <1373655354.10804.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Jul 2013 11:55:54 -0700

> On Fri, 2013-07-12 at 11:33 -0700, Yuchung Cheng wrote:
>> Change snmp RETRANSFAILS stat to include timeout retransmit failures
>> in addition to other loss recoveries.
>> 
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
