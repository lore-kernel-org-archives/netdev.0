From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 12:16:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121603.1cc70937.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<20030819145403.GA3407@alpha.home.local>
	<20030819170751.2b92ba2e.skraw@ithnet.com>
	<20030819085717.56046afd.davem@redhat.com>
	<20030819185219.116fd259.skraw@ithnet.com>
	<1061319864.30565.52.camel@dhcp23.swansea.linux.org.uk>
	<20030819120131.1999b1ec.davem@redhat.com>
	<091f01c36686$dade2bf0$c801a8c0@llewella>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, skraw@ithnet.com, willy@w.ods.org,
   richard@aspectgroup.co.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
In-Reply-To: <091f01c36686$dade2bf0$c801a8c0@llewella>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 21:19:44 +0200
"Bas Bloemsaat" <bloemsaa@xs4all.nl> wrote:

> > Indeed, would people stop quoting from RFC 985 and
> > RFC 826.
> 
> RFC 826 is referenced from 1009 as describing ARP. So in effect it does
> define a standard.

The RFC 826 document clearly says, at the top, "This is not
an Internet Standard"

It does not define a standard.  And given that it really isn't
surprising it has errors in it as we've clearly shown in these
threads.  The authors of said document didn't scuritinize it
to the level it would need to be in order to truly be a standards
document people must follow to have a conformant implementation.
