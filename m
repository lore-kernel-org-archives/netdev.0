From: jamal <hadi@cyberus.ca>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 20 Aug 2003 11:28:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061393295.1030.54.camel@jzny.localdomain>
References: <353568DCBAE06148B70767C1B1A93E625EAB61@post.pc.aspectgroup.co.uk>
	 <1061393011.1029.51.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, skraw@ithnet.com, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <1061393011.1029.51.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-08-20 at 11:23, jamal wrote:
> What Dave meant is the state machine used in 2461 for IPV6 is actually
> used in v4 as well. 

I should have said in linux - dont think in any BSD derived OSes.
To be specific look at the neighbor code.

cheers,
jamal
