From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more improvement to dev_alloc_name -- strnchr
Date: Mon, 19 Jan 2004 21:25:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119212537.5d73a031.davem@redhat.com>
References: <1074302619.40088e9bd44a6@www.geekmail.cc>
	<20040119113204.5913a8d6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ap@cipherica.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040119113204.5913a8d6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 11:32:04 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Okay, this patch avoids the loop if no wildcarding present, and keeps
> the same behaviour as original.  It adds the string function strnchr
> to avoid searching past the maximum ifname size to find the format character.

I'm deferring this until the next 2.6.x-pre starts up as well.
Please resend at that time.

Thanks Stephen.
