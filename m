From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 19:00:48 +0100
Message-ID: <20050131180048.GA24851@xi.wantstofly.org>
References: <1107123123.8021.80.camel@jzny.localdomain> <200501311614.31397.hasso@estpak.ee> <1107181551.7847.193.camel@jzny.localdomain> <200501311646.14322.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200501311646.14322.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 31, 2005 at 04:46:14PM +0200, Hasso Tepper wrote:

> This is somewhat related to killing the chance to use iptables as well ... 
> Iptables has better documentation and people use it just because of that.

I'm afraid I have to agree on this one.  The idea behind iptables is
easy to grasp, whereas tc isn't totally obvious, and all tc 'tutorials'
out there just give you a long list of commands to type in but don't
really explain you what goes on under the hood.

And you can't just expect everyone to "Go look at the source."


--L
