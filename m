From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Fri, 20 May 2005 01:15:37 +0200
Message-ID: <428D1E19.9030204@tpack.net>
References: <20050511230309.GA21547@gondor.apana.org.au> <1115891821.30106.86.camel@tsc-6.cph.tpack.net> <20050512103639.GA25631@gondor.apana.org.au> <20050519.130859.115641546.davem@davemloft.net> <20050519213839.GC24024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        chamas@h4.dion.ne.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050519213839.GC24024@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, May 19, 2005 at 01:08:59PM -0700, David S. Miller wrote:
> 
>>Ok, I think I got all the patches straight.  All of Tommy's
>>patches combined together look like this diff in my tree.
>>Please double check it.
> 
> Yes this is the one.

Yup. This combination fixes both problems.

Thanks,
Tommy
