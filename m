From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 19 Sep 2004 19:04:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095635068.1050.125.camel@jzny.localdomain>
References: <414D0CCD.90209@eurodev.net>
	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>  <414E0E75.30108@eurodev.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <414E0E75.30108@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo,

Please dont be discouraged by this. You have some valuable contribution
it just needs to be put in proper context.
I am sure Herbert will be than happy to help you clean the patch as will
I when i get cycles.
Post the stress tool when you get the chance.
 
cheers,
jamal

On Sun, 2004-09-19 at 18:55, Pablo Neira wrote:
> Hi Jamal,
> 
> jamal wrote:
> 
> >Theres one valuable piece in his patch. Ability to congestion control
> >the kernel so user space can clear the socket queue. The alternative is
> >an overun. You have shot a hole in the workqueue approach. May i also
> >recommend we revert the patch until we have a better resolution, Dave?
> >  
> >
> 
> whatever you decided I'll be ok to improve the solution
> 
> >Pablo you really need to provide some good testcases to prove this.
> >  
> >
> 
> Jamal, I told you that I made a tool to stress netlink sockets, I think 
> that it could help. I'll post in some hours to the maillist.
> 
> regards,
> Pablo
> 
