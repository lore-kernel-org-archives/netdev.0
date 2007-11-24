From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 0/3] PowerPC: ibm_newemac minor fixes.
Date: Sat, 24 Nov 2007 12:31:34 +1100
Message-ID: <1195867894.7195.40.camel@pasglop>
References: <20071123190747.GA25654@ru.mvista.com>
	<1195867102.7195.31.camel@pasglop>  <47477C55.8090209@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <47477C55.8090209@garzik.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-11-23 at 20:20 -0500, Jeff Garzik wrote:
> Benjamin Herrenschmidt wrote:
> > On Fri, 2007-11-23 at 22:07 +0300, Valentine Barshak wrote:
> > 
> >> These patches have some minor ibm_newemac fixes.
> > 
> > All 3 patches look good, thanks. I'll sign them off and forward them
> > to Jeff in my next batch.
> > 
> > Jeff, did you already pick up my previous drop of EMAC patches from last
> > week for .25 or not ? If not, I will resend the whole lot along with
> > Valentine's patches sometime next week.
> 
> Just got back from Thanksgiving holiday, and am about to go through the 
> lot that's sitting in my inbox.
> 
> Just let me know what you would prefer me to do, starting from today.

Then wait for my next batch and ignore previous patches, except the
one titled "ibm_newemac: Fix possible lockup on close" which is a 2.6.24
bug fix.

Thanks !

Cheers,
Ben.
