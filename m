From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 08:52:08 -0400
Message-ID: <1114606328.7670.29.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <426F830E.4060404@trash.net>
	 <1114604912.7670.25.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <1114604912.7670.25.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-27-04 at 08:28 -0400, Jamal Hadi Salim wrote:
> On Wed, 2005-27-04 at 14:18 +0200, Patrick McHardy wrote:
> 
> > struct xfrm_policy doesn't have an id member in my tree. Did I miss
> > something or do you mean to use index?
> > 
> 
> I meant index, sorry. I am going to give it a quick test in about 3
> minutes.
> 

Sorry, cant test, have to rush to work - and it looks like the
priorities may interfere. I will test when i get back home. It also
appears there may be a bug in ip x.


cheers,
jamal
