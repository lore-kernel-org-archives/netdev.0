From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (repost) TCP westwood bw_sample
Date: Mon, 15 Mar 2004 12:57:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315125738.6a601e05.davem@redhat.com>
References: <20040312093010.650caaa0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040312093010.650caaa0@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Mar 2004 09:30:10 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> TCP westwood bw_sample element in tcp_opt is set but never used.
> Repost of patch, because forgot part which removes it from tcp.h

Applied, thanks Stephen.
