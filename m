From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] PKT_SCHED: Avoid duplicated TCA_STATS TLVs for HTB
 and HFSC
Date: Fri, 22 Oct 2004 15:20:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022152031.0e7811a9.davem@davemloft.net>
References: <20041022100517.GY21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041022100517.GY21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 12:05:17 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Backport of the equivalent 2.6 fixes.
> 
> Qdiscs are not supposed to dump TCA_STATS, it is done in generic code part.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
