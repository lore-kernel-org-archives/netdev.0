From: James Morris <jmorris@intercode.com.au>
Subject: Re: Dump of TCP hang in established state
Date: Wed, 14 May 2003 19:08:27 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
References: <1052841090.13492.20.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1052841090.13492.20.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 13 May 2003, Martin Josefsson wrote:

> - There are those mysterious TCP hangs of established state sockets. 
>   Someone has to get a good log in order for us to effectively debug this.
> 
> I think this is what I've seen a few times when using distcc.

Does anyone know if the other hangs are seen when the app is using 
TCP_CORK (like distcc does) ?


- James
-- 
James Morris
<jmorris@intercode.com.au>
