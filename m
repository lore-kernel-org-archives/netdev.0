From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/4) delay scheduler enqueue always succeeds.
Date: Fri, 18 Jun 2004 13:27:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618132711.6784b460.davem@redhat.com>
References: <20040617155556.5f53dff0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040617155556.5f53dff0@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 15:55:56 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> If underlying fifo enqueue fails, return the status not 0.
> Same patch should apply to both 2.6 and 2.4

Duh :)  Applied, thanks Stephen.
