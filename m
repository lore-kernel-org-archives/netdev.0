From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH net-next 1/2] net: ndisc.c: fix coding style issue
Date: Fri, 26 May 2017 21:55:32 +0800
Message-ID: <1495806932.5755.4.camel@163.com>
References: <1495805019-2919-1-git-send-email-cugyly@163.com>
         <CAPA1RqDqyZicNWM8arSvMfQjmy_A=LLEjtTwH8KTza4WwQ_dsg@mail.gmail.com>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: network dev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>, David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
        <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:51205 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751309AbdEZNzr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 09:55:47 -0400
In-Reply-To: <CAPA1RqDqyZicNWM8arSvMfQjmy_A=LLEjtTwH8KTza4WwQ_dsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 五, 2017-05-26 at 22:45 +0900, 吉藤英明 wrote:
> Hi,
> 
> 2017-05-26 22:23 GMT+09:00 yuan linyu <cugyly@163.com>:
> > 
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > 
> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > ---
> >  net/ipv6/ndisc.c | 109 ++++++++++++++++++++++++++++---------------------------
> >  1 file changed, 55 insertions(+), 54 deletions(-)
> Sorry, I don't think this kind of change for style is good
> bacause this makes effort of  backport more difficult.
hi, i can't understand. 
if any change of this code you decide to backport, it need effort,
not only important fix.

do I miss your point ?
> 
> --yoshfuji
> 
