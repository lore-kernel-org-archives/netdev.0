From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/4] ARM: OMAP3: Add SMSC911X support to Overo
	platform	(V2)
Date: Tue, 17 Mar 2009 09:18:02 +0100
Message-ID: <OF29DE8A9F.A26662CB-ON8025757C.002D018B-8025757C.002D970C@smsc.com>
References: <20090316180800.GG19229@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.arm.linux.org.uk, linux-omap@vger.kernel.org,
	Steve Sakoman <sakoman@gmail.com>, netdev@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <20090316180800.GG19229@atomide.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Hi Tony,

Tony Lindgren <tony@atomide.com> wrote on 16/03/2009 18:08:01:

> * Russell King - ARM Linux <linux@arm.linux.org.uk> [090315 10:37]:
> > On Sun, Mar 15, 2009 at 10:13:47AM -0700, Steve Sakoman wrote:
> > > On Sun, Mar 15, 2009 at 10:00 AM, Russell King - ARM Linux
> > > <linux@arm.linux.org.uk> wrote:
> > > > On Sun, Mar 15, 2009 at 09:36:25AM -0700, Steve Sakoman wrote:
> > > >> On Sun, Mar 15, 2009 at 8:38 AM, Russell King - ARM Linux
> > > >> <linux@arm.linux.org.uk> wrote:
> > > >> > On Fri, Mar 13, 2009 at 03:44:53PM -0700, Tony Lindgren wrote:
> > > >> >> Gumstix will soon be shipping a variant of their Summit board 
that
> > > >> >> includes an SMSC LAN9221 ethernet interface.  This patch 
provides
> > > >> >> support via the smsc911x driver when enabled in kernel config.
> > > >> >
> > > >> > Does this actually work with the smsc911x driver which is 
> in mainline,
> > > >> > or is it dependent on the smsc911x patches from Steve 
Glendinning?
> > > >>
> > > >> For the shipping Overo kernel, I build with 2 of Steve's 
> patches, copied below.
> > > >
> > > > That doesn't help answer the question.  What we need to know is 
whether
> > > > this patch works alone?  If not, do we know for sure that 
> Steve's patches
> > > > are going in during the next merge window?
> > > 
> > > It does not work without the 2 mentioned patches (IRQ's never 
> get handled).
> > 
> > So I suggest that this patch is handed over to Steve to submit with 
his
> > set of patches.
> 
> I've added Steve Glendinning to the Cc.
> 
> I'll drop this from my queue, Steve Sakoman please email this to Steve
> Glendinning for inclusion to his queue.
> 

Yes, David has included all the IRQ patches in net-next-2.6, so they will 
be merged in the next merge window.

Steve
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
