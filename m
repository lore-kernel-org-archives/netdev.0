From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] deliver_skb cleanup
Date: Tue, 24 Aug 2004 17:25:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824172534.6f508ea9.davem@redhat.com>
References: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
	<20040824113537.68c570fe@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040824113537.68c570fe@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 11:35:37 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Another cleanup in netif_receive_skb. Move rcu_read_lock up a little,
> since it needs to be done in both branches anyway. Also whitespace fix.

Also applied, thanks Stephen.
