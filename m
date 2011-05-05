From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Thu, 5 May 2011 21:46:01 +0200
Message-ID: <20110505194601.GA10565@lunn.ch>
References: <20110408130643.GA8730@orbit.nwl.cc>
	<20110505141107.GC30443@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu, Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>, Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110505141107.GC30443@orbit.nwl.cc>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2011 at 04:11:07PM +0200, Phil Sutter wrote:
> Hi,
> 
> Hasn't anyone experienced this bug but me? Can anyone reproduce the
> described behaviour on his Kirkwood-based (or even generic ARM) machine?
> I am still not sure if this is a problem of just my CPU or common
> amongst Kirkwood/VIPT/ARM machines.

Hi Phil

I can reproduce it on a Kirkwood:

[    0.000000] CPU: Feroceon 88FR131 [56251311] revision 1 (ARMv5TE), cr=00053977

     Andrew
