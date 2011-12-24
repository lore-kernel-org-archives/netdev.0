From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] netem: fix a typo in explain()
Date: Sat, 24 Dec 2011 11:21:42 -0800
Message-ID: <20111224112142.1839d76d@nehalam.linuxnetplumber.net>
References: <1324701553.2915.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35767 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab1LXTVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 14:21:44 -0500
In-Reply-To: <1324701553.2915.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Dec 2011 05:39:13 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  tc/q_netem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tc/q_netem.c b/tc/q_netem.c
> index e9a601b..b1fd452 100644
> --- a/tc/q_netem.c
> +++ b/tc/q_netem.c
> @@ -38,7 +38,7 @@ static void explain(void)
>  "                 [ loss random PERCENT [CORRELATION]]\n" \
>  "                 [ loss state P13 [P31 [P32 [P23 P14]]]\n" \
>  "                 [ loss gemodel PERCENT [R [1-H [1-K]]]\n" \
> -"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
> +"                 [ reorder PERCENT [CORRELATION] [ gap DISTANCE ]]\n");
>  }
>  
>  static void explain1(const char *arg)
> 
> 

Applied
