From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [sparse] ip_rt_ioctl argument is user pointer
Date: Tue, 22 Jun 2004 17:11:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622171129.0b353008.davem@redhat.com>
References: <20040622160022.75db69bb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040622160022.75db69bb@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 16:00:22 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The function ip_rt_ioctl expects a pointer to a user route structure, so define
> it that way and cast as appropriate.

Applied, thanks Stephen.
