From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 16:46:14 +0200
Message-ID: <200501311646.14322.hasso@estpak.ee>
References: <1107123123.8021.80.camel@jzny.localdomain> <200501311614.31397.hasso@estpak.ee> <1107181551.7847.193.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107181551.7847.193.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Unfortunately this "index" thing continues to be a big secret although i
> have pointed it a few times. Bart should probably add it to his HOWTO.

All this stuff deserves better documentation ;). Call me oldfashioned, but 
IMHO would be good start to have all keywords at least somewhat documented 
in iproute2 man pages. I know, writing documentation is boring task etc, 
but at least you should mention all features in man pages. This gives to 
someone at least chance to kick you "hey, what's this?" ;).

This is somewhat related to killing the chance to use iptables as well ... 
Iptables has better documentation and people use it just because of that.

Just checked ... "tc action help" in newest iproute2 returns nothing as 
well :(.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
