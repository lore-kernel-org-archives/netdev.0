From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: Re: oops in skbuff.c
Date: Fri, 17 Oct 2003 22:50:58 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F907252.1538.AC80B30@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-net-owner@vger.kernel.org>
To: James Morris <jmorris@redhat.com>,
	LK-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Content-description: Mail message body
List-Id: netdev.vger.kernel.org

> > On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> > 
> > >  panics. Copying more than 4 GB to the samba share also lets the 
> > > kernel panic with an OOPS.
> > 
> > Does the above cause a panic for the 2.6-test kernels?
> > Do you have netfilter enabled, and if so, any iptables modules loaded?
> > 
> > 
> I did a mistake. iptables is installed but no rules added. I'll 
> remove iptables and rerun the check.

For being sure I removed iptables but again the oops happened. I also 
tried kernel 2.4.18 without success.

Does anybody have a clue how to go on?

--
Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de

