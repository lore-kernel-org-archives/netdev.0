From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for
	routing rules
Date: 07 Apr 2005 21:11:22 -0400
Message-ID: <1112922682.1088.62.camel@jzny.localdomain>
References: <20050407213838.GW26731@postel.suug.ch>
	 <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
	 <20050407223847.GX26731@postel.suug.ch>
	 <1112915616.1089.27.camel@jzny.localdomain>
	 <20050407232427.GY26731@postel.suug.ch>
	 <1112921300.1088.54.camel@jzny.localdomain>
	 <20050408010406.GZ26731@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050408010406.GZ26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-04-07 at 21:04, Thomas Graf wrote:

> ...  this may include rule systems that do not depend on
> CONFIG_IP_MULTIPLE_TABLES, e.g. IPv6 is likely to get an own config option
> for this. Or someday we might have DECnet rules? I don't know.
> 

Ok, fair enough.

BTW Decnet already has it for family PF_DECnet ;-> 
[I dont think there has existed a decnet as sophisticated as the one we
have - too bad its not used that much].

cheers,
jamal
