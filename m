From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 14:53:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818145316.3a81f70c.skraw@ithnet.com>
References: <20030728213933.F81299@coredump.scriptkiddie.org>
	<200308171509570955.003E4FEC@192.168.128.16>
	<200308171516090038.0043F977@192.168.128.16>
	<1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
	<200308171555280781.0067FB36@192.168.128.16>
	<1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
	<200308171759540391.00AA8CAB@192.168.128.16>
	<1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk>
	<200308171827130739.00C3905F@192.168.128.16>
	<1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk>
	<20030817224849.GB734@alpha.home.local>
	<20030817223118.3cbc497c.davem@redhat.com>
	<20030818133957.3d3d51d2.skraw@ithnet.com>
	<20030818044419.0bc24d14.davem@redhat.com>
	<20030818143401.1352d158.skraw@ithnet.com>
	<20030818053007.7852ca77.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
   lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818053007.7852ca77.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 05:30:07 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Mon, 18 Aug 2003 14:34:01 +0200
> Stephan von Krawczynski <skraw@ithnet.com> wrote:
> 
> > what is the _positive_ outcome of this
> > implementation compared to others?
> 
> If you're not willing to think I can't help you resolve
> the questions you have.
> 
> If you don't understand source address selection, than it's
> not possible for me to have an intellegent conversation about
> this topic.
> 
> So you need to make this crucial first step.

Sorry, David. Your argument would only be valid, if there weren't other
implementations that behave differently. But in fact there are, and there are
patches for linux that do just the same. _And_ you did not explain so far why
these implementations should not be RFC-conform or else illegal. So there is no
validity in your claim one has to understand why the designer did what he did
to follow the discussion. In fact it is rather up to the designer to explain to
the users why he did it in another way other designers did, i.e. what is
_better_ about _this_ way compared to others.
Because if there is nothing better then the implementation is legal but
contestable, because all scenarios discussed so far have more complex solutions
then with other implementations.
Don't get me wrong, this is no technical argument. It is purely darwinism,
"legal and easy" is superior to "legal and complex" (as long as there are no
other benefits).

Regards,
Stephan
