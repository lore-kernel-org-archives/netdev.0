From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 10:34:12 -0500
Message-ID: <1107185652.1075.3.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311614.31397.hasso@estpak.ee>
	 <1107181551.7847.193.camel@jzny.localdomain>
	 <200501311646.14322.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501311646.14322.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 09:46, Hasso Tepper wrote:
> jamal wrote:
> > Unfortunately this "index" thing continues to be a big secret although i
> > have pointed it a few times. Bart should probably add it to his HOWTO.
> 
> All this stuff deserves better documentation ;). Call me oldfashioned, but 
> IMHO would be good start to have all keywords at least somewhat documented 
> in iproute2 man pages. I know, writing documentation is boring task etc, 
> but at least you should mention all features in man pages. This gives to 
> someone at least chance to kick you "hey, what's this?" ;).
> 

But 50 emails later noone documented anything .. And every summer
someone tries to write a qdisc to achive this ;->

> This is somewhat related to killing the chance to use iptables as well ... 
> Iptables has better documentation and people use it just because of that.
> 
> Just checked ... "tc action help" in newest iproute2 returns nothing as 
> well :(.

Should work. Are you sure you got the latest one?
Also make sure you compile tc action in the scheduler part of kernel
config.

cheers,
jamal
