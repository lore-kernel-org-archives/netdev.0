From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 12:10:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121003.7b5031c7.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
	<1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
	<1061317825.3744.7.camel@athena.fprintf.net>
	<20030819112912.359eaea6.davem@redhat.com>
	<1061320363.3744.14.camel@athena.fprintf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, richard@aspectgroup.co.uk, skraw@ithnet.com,
   willy@w.ods.org, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, bloemsaa@xs4all.nl, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Gryniewicz <dang@fprintf.net>
In-Reply-To: <1061320363.3744.14.camel@athena.fprintf.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Aug 2003 15:12:43 -0400
Daniel Gryniewicz <dang@fprintf.net> wrote:

> (And it's not just cisco, all the *BSDs (and therefore anything
> that took the BSD stack such as MS) work this way too.)

Not true.  Microsoft systems do respond properly to these ARPs.
