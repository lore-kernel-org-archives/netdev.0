From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Remove bogus #ifdef CONFIG_SYSCTL in TCP
Date: Tue, 19 Oct 2004 22:07:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019220702.052aa0a4.davem@davemloft.net>
References: <20041012163806.GA4223@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041012163806.GA4223@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2004 18:38:06 +0200
Andi Kleen <ak@suse.de> wrote:

> Modular IPv6 needs these variables always exported, even when 
> CONFIG_SYSCTL is not enabled.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Applied, thanks Andi.
