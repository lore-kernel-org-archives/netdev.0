From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [RFT][PATCH] ax25 using seq_file
Date: Mon, 25 Aug 2003 00:35:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030825003535.A25139@jeroen.pe1rxq.ampr.org>
References: <20030812230951.E28977@jeroen.pe1rxq.ampr.org> <20030812153901.6e700dcb.shemminger@osdl.org> <20030813010301.K28977@jeroen.pe1rxq.ampr.org> <20030812172151.7de0c950.shemminger@osdl.org> <20030813031159.6c6c9629.davem@redhat.com> <20030813173446.A2604@jeroen.pe1rxq.ampr.org> <20030813084252.7b667fb8.davem@redhat.com> <20030820204518.C5568@jeroen.pe1rxq.ampr.org> <20030822131547.0d95fb16.shemminger@osdl.org> <20030824042911.785aff76.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <shemminger@osdl.org>, linux-hams@vger.kernel.org,
   ralf@linux-mips.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S . Miller" <davem@redhat.com>
In-Reply-To: <20030824042911.785aff76.davem@redhat.com>; from davem@redhat.com on Sun, Aug 24, 2003 at 13:29:11 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2003.08.24 13:29:11 +0200 David S. Miller wrote:
> On Fri, 22 Aug 2003 13:15:47 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Convert AX25 to use the seq_file interface for it's /proc hook.
> > 
> > Jeroen could you test this with real hardware, since without hardware
> > the table always comes up empty which is not a good enough test.
> 
> Meanwhile I've applied this.  If problems are found you can
> send me fixes.
> 

No problems so far.... 
I gave it a try this evening and until now it keeps running fine with the
seq_file patches. 
I can read the /proc files as much as I like with varying connections going
on.

Jeroen
