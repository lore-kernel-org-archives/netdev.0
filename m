From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT][PATCH] ax25 using seq_file
Date: Sun, 24 Aug 2003 04:29:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824042911.785aff76.davem@redhat.com>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
	<20030812172151.7de0c950.shemminger@osdl.org>
	<20030813031159.6c6c9629.davem@redhat.com>
	<20030813173446.A2604@jeroen.pe1rxq.ampr.org>
	<20030813084252.7b667fb8.davem@redhat.com>
	<20030820204518.C5568@jeroen.pe1rxq.ampr.org>
	<20030822131547.0d95fb16.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pe1rxq@amsat.org, linux-hams@vger.kernel.org, ralf@linux-mips.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030822131547.0d95fb16.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2003 13:15:47 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert AX25 to use the seq_file interface for it's /proc hook.
> 
> Jeroen could you test this with real hardware, since without hardware
> the table always comes up empty which is not a good enough test.

Meanwhile I've applied this.  If problems are found you can
send me fixes.
