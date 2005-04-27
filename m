From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 14:18:22 +0200
Message-ID: <426F830E.4060404@trash.net>
References: <1114602874.7670.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1114602874.7670.4.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> I think this is a reasonable thing to have. I should be able to update
> (just like delete or get) a policy by id. And that it trumps a selector
> when both are specified..

struct xfrm_policy doesn't have an id member in my tree. Did I miss
something or do you mean to use index?

Regards
Patrick
