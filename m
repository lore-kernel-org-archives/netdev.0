From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: net-next STATUS page
Date: Thu, 13 Jul 2017 13:47:29 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1707131340400.29961@n3.vanv.qr>
References: <20170711.072416.2014054416066621222.davem@davemloft.net> <20170711115841.64d9aa1d@xeon-e3> <20170713085639.GA2060@nanopsycho> <572310a4-5914-52d2-6688-c899f3c7f245@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jiri@resnulli.us>,
        Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <572310a4-5914-52d2-6688-c899f3c7f245@mellanox.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2017-07-13 13:32, Saeed Mahameed wrote:
>>>
>>>> Therefore, in order to avoid any and all confusion I have created this
>>>> web site:
>>>>
>>>>  http://vger.kernel.org/~davem/net-next.html
>
> You will need an image processing algorithm to determine whether it is open or
> close, i have some good neural network algorithms if you are interested :)

That's not going to win any hacker prize.

A much more resource-saving approach is to just strcasestr(s, "closed") 
in the raw text. …at least while the page maintainer remains 
good-hearted.
