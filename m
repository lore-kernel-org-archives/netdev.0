From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: fix queue limits in multiple qdiscs
Date: Tue, 18 Nov 2003 17:34:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118173457.5c85c671.davem@redhat.com>
References: <3FB39A2D.5020000@trash.net>
	<1069076955.1076.23.camel@jzny.localdomain>
	<3FB8DF9F.7030509@trash.net>
	<1069081284.1024.23.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069081284.1024.23.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Nov 2003 10:01:24 -0500
jamal <hadi@cyberus.ca> wrote:

> Like i said it is valid - but i wouldnt go out of my way to fix it
> (especially when 2.6 is frozen).

I agree with this sentiment, but only in part.

Considering:

1) The output from 'tc' is very confusing and quite stupid.
2) Patrick did all the work to fix this bug.
3) His patch is %100 straight forward, simply, and easy to verify.

I am going to apply his patch.

Thanks Patrick.
