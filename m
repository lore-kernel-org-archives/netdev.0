From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (8/9) bridge - support lots of 1k ports
Date: Fri, 16 Apr 2004 14:22:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416142252.05481624.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413153308.6e0dd462@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413153308.6e0dd462@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:33:08 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Support >256 ports on a bridge.  Use the suggestion of reducing
> the number of bits of priority and increasing the number of bits
> for port number.

Seems sane, applied.
