From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 15:08:31 -0500
Message-ID: <1107202111.1076.537.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311614.31397.hasso@estpak.ee>
	 <1107181551.7847.193.camel@jzny.localdomain>
	 <200501311646.14322.hasso@estpak.ee>
	 <20050131180048.GA24851@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050131180048.GA24851@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 13:00, Lennert Buytenhek wrote:
> On Mon, Jan 31, 2005 at 04:46:14PM +0200, Hasso Tepper wrote:
> 
> > This is somewhat related to killing the chance to use iptables as well ... 
> > Iptables has better documentation and people use it just because of that.
> 
> I'm afraid I have to agree on this one.  

Well, if you look at the 2 requirements behind IMQ, has nothing todo
with iptables i.e does not at all require presence of iptables.
So motivation is to meet those requirements not kill iptables.

> The idea behind iptables is
> easy to grasp, whereas tc isn't totally obvious, and all tc 'tutorials'
> out there just give you a long list of commands to type in but don't
> really explain you what goes on under the hood.
> 
> And you can't just expect everyone to "Go look at the source."

Agreed, tc is less usable and has a lot less people puking code at it.
The usability part has to be fixed. And i think you will see that with
ematch and eaction code showing up. Credit goes to Bart and co and their
website for putting a lot of docs together. Usability certainly needs to
improve!

cheers,
jamal
