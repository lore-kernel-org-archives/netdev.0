From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (3/9) bridge - jiffies_to_clock
Date: Fri, 16 Apr 2004 14:14:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416141425.37bb59d8.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413152037.5e28054d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413152037.5e28054d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:20:37 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Rather than doing the math directly, use jiffies_to_clock functions
> to convert from user hz to jiffies.

Applied.
