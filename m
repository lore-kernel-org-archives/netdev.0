From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] gre: fix error handler
Date: Thu, 16 Jun 2016 04:40:17 -0700
Message-ID: <1466077217.7945.210.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465967701.7945.200.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465969537.7945.201.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160616094059.6ce42eb6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33211 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbcFPLkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 07:40:21 -0400
Received: by mail-pf0-f179.google.com with SMTP id i123so15616304pfg.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 04:40:21 -0700 (PDT)
In-Reply-To: <20160616094059.6ce42eb6@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-16 at 09:40 +0200, Jiri Benc wrote:

> Reviewed-by: Jiri Benc <jbenc@redhat.com>
> 
> I know this has already been applied. Didn't get to it earlier, sorry.
> The patch looks good. Thanks!

Thanks Jiri for reviewing it !
