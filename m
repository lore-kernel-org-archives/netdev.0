From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [sparse] add annotation to sock_filter.h
Date: Thu, 17 Jun 2004 11:00:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617110026.1b92556f.davem@redhat.com>
References: <20040617102622.5f07fc56@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040617102622.5f07fc56@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 10:26:22 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Since sock_fprog is argument in ioctl, the filter pointer needs to be annotated.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
