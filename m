From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH iproute2] ss: add fastopen support
Date: Fri, 3 May 2013 17:08:40 -0700
Message-ID: <CAK6E8=fdwcFf0yeueQt+Et3MkiKY2dyuaVy6982dzUQoOxohFA@mail.gmail.com>
References: <1364590317.5113.63.camel@edumazet-glaptop> <20130329.165659.1297013790823482161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:41098 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab3EDAJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 20:09:04 -0400
Received: by mail-la0-f51.google.com with SMTP id ep20so1978442lab.10
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 17:09:02 -0700 (PDT)
In-Reply-To: <20130329.165659.1297013790823482161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 29, 2013 at 1:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Mar 2013 13:51:57 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> ss -i can output "fastopen" attribute if socket used Fast Open
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Reviewed-by: David S. Miller <davem@davemloft.net>
Acked-by: Yuchung Cheng <ycheng@google.com>
