From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] deliver_skb cleanup
Date: Tue, 24 Aug 2004 17:23:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824172353.52bb3a29.davem@redhat.com>
References: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 11:07:11 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Cleanup of deliver_skb: get rid of unused argument and use it
> in the NET_CLS_ACT hook.

Looks good, applied.
