From: "David S. Miller" <davem@davemloft.net>
Subject: Re: AX.25 cb lookup patch
Date: Tue, 9 Nov 2004 22:05:44 -0800
Message-ID: <20041109220544.5841b9b7.davem@davemloft.net>
References: <20041109033617.GB621@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20041109033617.GB621@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Nov 2004 04:36:18 +0100
Ralf Baechle <ralf@linux-mips.org> wrote:

> Ax AX.25 connection is identified only by it's source and destination,
> not by the device it's routed through, so fix the connection block
> lookup to ignore the device of a connection.  This fixes dying connections
> in case of an AX.25 routing flap.

Applied, thanks Ralf.
