From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/4) packet scheduler exports
Date: Tue, 29 Jun 2004 14:33:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629143347.510a1531.davem@redhat.com>
References: <20040629140014.1aba3719@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040629140014.1aba3719@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 14:00:14 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The packet scheduling code has some ugly define's which were to deal with
> configuration possibilities and the old style module exports.  With the current
> 2.6 method, this is unnecessary.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied.
