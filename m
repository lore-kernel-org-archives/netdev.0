From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: Re: [PATCH 0/4] - pktgen: refinements and small fixes (V2).
Date: Mon, 30 Jan 2006 10:15:09 -0200
Message-ID: <20060130101509.674bb081.lcapitulino@mandriva.com.br>
References: <20060129232342.1e481f9a@localhost>
	<17373.62964.203852.42375@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932241AbWA3MPS@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17373.62964.203852.42375@robur.slu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jan 2006 12:18:12 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

| 
| Luiz Fernando Capitulino writes:
| 
|  > [PATCH 1/4]  pktgen: Lindent run.
|  > [PATCH 2/4]  pktgen: Ports thread list to Kernel list implementation.
|  > [PATCH 3/4]  pktgen: Fix kernel_thread() fail leak.
|  > [PATCH 4/4]  pktgen: Fix Initialization fail leak.
|  > 
|  >  The changes from V1 are:
|  > 
|  >  1. More fixes made by hand after Lindent run
|  >  2. Re-diffed agains't Dave's net-2.6.17 tree
| 
|  Should be fine I've used the previous version of the patches for a
|  couple of days now. Thanks.

 Ok Robert, I'll try to finish the interface list port this week.

| 
|  Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
| 
|  Cheers.	
| 					--ro

-- 
Luiz Fernando N. Capitulino
