From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCHSET 0/16] More gnet_stats conversions
Date: Thu, 21 Oct 2004 22:48:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021224812.4a7e2c35.davem@davemloft.net>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 14:32:09 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> This patchset contains requeues statistics, TLV type max cleanups, and
> more conversions to the new generic statistic interface.
> 
> It converts all qdiscs to dump their xstats via gnet_stats_copy_app and
> converts all class statistics in classful qdiscs to the new API.

Thomas has been a very busy boy :-)

All nice and straightforward transformations, nice work.

All patches applied, thanks Thomas.
