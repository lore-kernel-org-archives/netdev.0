From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] etherdevice.h -- make constant args
Date: Thu, 8 Apr 2004 14:51:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040408145149.65831d1e.davem@redhat.com>
References: <20040408110653.003174e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040408110653.003174e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Apr 2004 11:06:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Rather than forcing cast in some new validation code in the bridge;
> please fix a couple of inline functions should have "const" on args.

Applied, thanks Stephen.
