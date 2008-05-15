From: Olaf Hering <olaf@aepfle.de>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol changes
Date: Thu, 15 May 2008 17:49:48 +0200
Message-ID: <20080515154948.GA23647@aepfle.de>
References: <20080515121340.GA23033@aepfle.de>
	<1551EAE59135BE47B544934E30FC4FC002AABCEE@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Matthew Carlson <mcarlson@broadcom.com>,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABCEE@nt-irva-0751.brcm.ad.broadcom.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, Michael Chan wrote:

> Olaf Hering wrote:
> 
> > Any ideas how to fix this?
> > What info do you need from the system?
> 
> Are you using eth0 or eth1?  The dmesg below shows that
> link came up on eth1 and IP address from DHCP was received.

I'm using eth1.
The log was done with the patch reverted.
