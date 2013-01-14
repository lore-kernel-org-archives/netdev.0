From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] ifb: dont hard code inet_net use
Date: Mon, 14 Jan 2013 08:13:45 -0500
Message-ID: <50F40489.70105@mojatatu.com>
References: <50F1699E.1000200@hartkopp.net>  <20130112.132316.2121287993605534669.davem@davemloft.net>  <20130112.133630.257139657732337147.davem@davemloft.net>  <1358046374.20249.1789.camel@edumazet-glaptop>  <20130113035013.GJ5259@kvack.org>  <1358056199.20249.2121.camel@edumazet-glaptop>  <50F2C860.1060602@mojatatu.com> <1358099194.8744.311.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f182.google.com ([209.85.210.182]:62402 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab3ANNNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 08:13:53 -0500
Received: by mail-ia0-f182.google.com with SMTP id x2so3561337iad.13
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 05:13:53 -0800 (PST)
In-Reply-To: <1358099194.8744.311.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-13 12:46 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> ifb should lookup devices in the appropriate namespace.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>


  Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
