From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/4) packet scheduler - eliminate guard from
 TDIFF_SAFE
Date: Tue, 29 Jun 2004 14:46:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629144622.36108944.davem@redhat.com>
References: <20040629140019.2efbf6f6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040629140019.2efbf6f6@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 14:00:19 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The last argument in the PSCHED_TDIFF_SAFE is no longer used;
> only usage eliminated by previous patch. It gets rid of a bad macro
> usage.

Yes, good cleanup after the csz bugfix.

Applied, thanks Stephen.
