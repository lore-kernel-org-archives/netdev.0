From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] allow large MTU on dummy net device
Date: Mon, 5 Jul 2004 15:48:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705154854.7d70728d.davem@redhat.com>
References: <20040630113754.5ae6b14a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040630113754.5ae6b14a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2004 11:37:54 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It is useful for testing to allow larger MTU value to be set on
> the dummy network device. The current code limits it to valid Ether mtu's.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied.
