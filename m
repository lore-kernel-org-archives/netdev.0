From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Resend: Re: PATCH: IPSEC acquire in presence of multiple
 managers
Date: Thu, 31 Mar 2005 21:13:40 -0800
Message-ID: <20050331211340.0e6fbdfb.davem@davemloft.net>
References: <1111795927.1089.749.camel@jzny.localdomain>
	<1111862131.1092.872.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@redhat.com, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1111862131.1092.872.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 26 Mar 2005 13:35:31 -0500
jamal <hadi@cyberus.ca> wrote:

> Apologies, The last patch had some a glitch in the filename. Dave please
> apply this one instead

Doesn't apply, in the current tree km_query() is marked static.

Please regenerate your patch and sorry for not getting to this
sooner.
