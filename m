From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 00:55:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414E0E75.30108@eurodev.net>
References: <414D0CCD.90209@eurodev.net>	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>	 <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095633569.1047.107.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

jamal wrote:

>Theres one valuable piece in his patch. Ability to congestion control
>the kernel so user space can clear the socket queue. The alternative is
>an overun. You have shot a hole in the workqueue approach. May i also
>recommend we revert the patch until we have a better resolution, Dave?
>  
>

whatever you decided I'll be ok to improve the solution

>Pablo you really need to provide some good testcases to prove this.
>  
>

Jamal, I told you that I made a tool to stress netlink sockets, I think 
that it could help. I'll post in some hours to the maillist.

regards,
Pablo
