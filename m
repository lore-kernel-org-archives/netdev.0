From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert packet scheduler API to single_open
Date: Thu, 11 Sep 2003 16:43:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911164350.346f5ab3.davem@redhat.com>
References: <20030905140104.6a9ed33a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030905140104.6a9ed33a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Sep 2003 14:01:04 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert /proc/net/psched to use seq_file; almost trivial.
> 
> Patch against 2.6.0-test4 bk latest.

Applied, thanks.
