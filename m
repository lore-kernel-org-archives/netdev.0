From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH net-next 1/2] net: ndisc.c: fix coding style issue
Date: Sat, 27 May 2017 06:08:17 +0800
Message-ID: <1495836497.2536.4.camel@163.com>
References: <1495805019-2919-1-git-send-email-cugyly@163.com>
         <CAPA1RqDqyZicNWM8arSvMfQjmy_A=LLEjtTwH8KTza4WwQ_dsg@mail.gmail.com>
         <1495806932.5755.4.camel@163.com>
         <CAPA1RqB1_ObcZc_rgE6HN+-PzsabWd2X=swGbkPxVLrzY60MKg@mail.gmail.com>
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
Received: from m12-15.163.com ([220.181.12.15]:44242 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1948784AbdEZWIm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 18:08:42 -0400
In-Reply-To: <CAPA1RqB1_ObcZc_rgE6HN+-PzsabWd2X=swGbkPxVLrzY60MKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 六, 2017-05-27 at 02:25 +0900, 吉藤英明 wrote:
> Hi,
> 
> 2017-05-26 22:55 GMT+09:00 yuan linyu <cugyly@163.com>:
> > 
> > On 五, 2017-05-26 at 22:45 +0900, 吉藤英明 wrote:
> > > 
> > > Hi,
> > > 
> > > 2017-05-26 22:23 GMT+09:00 yuan linyu <cugyly@163.com>:
> > > > 
> > > > 
> > > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > 
> > > > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > ---
> > > >  net/ipv6/ndisc.c | 109 ++++++++++++++++++++++++++++---------------------------
> > > >  1 file changed, 55 insertions(+), 54 deletions(-)
> > > Sorry, I don't think this kind of change for style is good
> > > bacause this makes effort of  backport more difficult.
> > hi, i can't understand.
> > if any change of this code you decide to backport, it need effort,
> > not only important fix.
> > 
> > do I miss your point ?
> Please let us minimize our effort when doing so.
> 
> If the style is not changed, we have more chance to apply the patch
> itself on top of old tree.
> 
> Thank you.
I don't know you hate this kind of changes,
from a code reader view, I like to see code with good style.
I am not happy when reading code with this kind of bad style.

And it only spend a command time to backport, right?
it will never spend your effort only if this code will not change in future.
> 
> > 
> > > 
> > > 
> > > --yoshfuji
> > > 
> > 
