From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 15:06:30 +0100
Message-ID: <20050131140630.GD31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <200501311438.01118.hasso@estpak.ee> <1107175673.7847.130.camel@jzny.localdomain> <200501311502.56796.hasso@estpak.ee> <20050131132819.GB31837@postel.suug.ch> <1107179140.7840.157.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107179140.7840.157.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Yeah, that would fix it. Note however, that i am trying to highly
> discourage use of iptables and i would rather let people who use
> iptables to suffer;-> (sounds rude i know).  At some point i plan to
> remove the dependency on iptables altogether.

Heh, I think it isn't rude, giving people a little clap to join
the "good side" isn't that bad ;->

> So i am not sure whether i should encourage pushing of this patch or not ;->

I don't care that much, the patch is there, everyone can patch and
distributions can pick it up. I agree that we should remove the
dependency on iptables but I'd also like to see the dependency on the
action bits to go away at the same time.
