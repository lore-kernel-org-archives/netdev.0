From: James Morris <jmorris@redhat.com>
Subject: Re: oops in skbuff.c
Date: Thu, 16 Oct 2003 15:15:00 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0310161512210.6059-100000@thoron.boston.redhat.com>
References: <3F8EF7B3.25278.5010BC6@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LK-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sebastian Piecha <spi@gmxpro.de>
In-Reply-To: <3F8EF7B3.25278.5010BC6@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003, Sebastian Piecha wrote:

>  panics. Copying more than 4 GB to the samba share also lets the 
> kernel panic with an OOPS.

Does the above cause a panic for the 2.6-test kernels?
Do you have netfilter enabled, and if so, any iptables modules loaded?


- James
-- 
James Morris
<jmorris@redhat.com>
