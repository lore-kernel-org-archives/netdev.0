From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [sparse] bad initializer in ipv6 netfilter.
Date: Wed, 21 Jul 2004 13:46:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721134633.5a495df7.davem@redhat.com>
References: <20040712150341.44a84ff6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040712150341.44a84ff6@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 12 Jul 2004 15:03:41 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Missing equal sign in C99 initializer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Viro pushed a fix for this into the tree before I got a chance
to apply yours :-)
