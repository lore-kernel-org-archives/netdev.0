From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [Kernel-janitors] Re: [PATCH 2.6.9-rc2 17/38]
 net/islpci_dev: replace schedule_timeout() with msleep()
Date: Sat, 02 Oct 2004 11:07:18 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <5.1.0.14.2.20041002105713.026705d8@pop.t-online.de>
References: <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<5.1.0.14.2.20041001084419.02570b18@pop.t-online.de> <20041001165523.GC11646@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
	prism54-devel@prism54.org, hvr@gnu.org,
	kernel-janitors@lists.osdl.org, jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20041001165523.GC11646@kroah.com>
References: <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

At 09:55 01.10.2004 -0700, Greg scribeth:
>On Fri, Oct 01, 2004 at 09:04:27AM +0200, Margit Schubert-While wrote:
> > At 00:15 01.10.2004 -0400, Jeff scribeth:
> > >I would rather see an msleep implementation in 2.4.x...
> >
> > Hear, hear.
> > And can we PLEASE have a
> > "#define HAVE_MSLEEP"  in delay.h ?!!!
> > (2.4. AND 2.6)
>
>No, this is not how the kernel source tree works, sorry.

Well it happened with netdev_priv  ;-)
(HAVE_NETDEV_PRIV)

Margit
