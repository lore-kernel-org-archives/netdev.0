From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: Re: oops in skbuff.c
Date: Fri, 17 Oct 2003 14:17:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8FF9F5.24611.8F1E08C@localhost>
References: <3F8EF7B3.25278.5010BC6@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>, LK-net <linux-net@vger.kernel.org>,
        <netdev@oss.sgi.com>
In-reply-to: <Xine.LNX.4.44.0310161512210.6059-100000@thoron.boston.redhat.com>
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 16 Oct 2003 at 15:15, James Morris wrote:

> On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> 
> >  panics. Copying more than 4 GB to the samba share also lets the 
> > kernel panic with an OOPS.
> 
> Does the above cause a panic for the 2.6-test kernels?
> Do you have netfilter enabled, and if so, any iptables modules loaded?
> 
> 
I did a mistake. iptables is installed but no rules added. I'll 
remove iptables and rerun the check.

--
Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de
