From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Documentation:change all arch/i386 to arch/x86 in
 Documentation
Date: Mon, 13 Jun 2011 17:06:01 -0700
Message-ID: <20110614000601.GO2326@linux.vnet.ibm.com>
References: <1307942898-3728-1-git-send-email-wanlong.gao@gmail.com>
 <20110613172344.GC2272@linux.vnet.ibm.com>
 <1308007716.2267.2.camel@Tux>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-video@atrey.karlin.mff.cuni.cz,
	xiyoulinuxkernelgroup@googlegroups.com, linux-kernel@zh-kernel.org,
	Dipankar Sarma <dipankar@in.ibm.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Nick Piggin <npiggin@kernel.dk>,
	Karsten Keil <isdn@linux-pingi.de>,
	Michal Marek <mmarek@suse.cz>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Martin Mares <mj@ucw.cz>, Harry Wei <harryxiyou@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Thomas Weber <weber@corscience.de>,
	Mike Frysinger <vapier.adi@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: Wanlong Gao <wanlong.gao@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1308007716.2267.2.camel@Tux>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2011 at 07:28:36AM +0800, Wanlong Gao wrote:
> On =E4=B8=80, 2011-06-13 at 10:23 -0700, Paul E. McKenney wrote:
> > On Mon, Jun 13, 2011 at 01:28:18PM +0800, Wanlong Gao wrote:
> > > From: Wanlong Gao <wanlong.gao@gmail.com>
> > >=20
> > > Change all "arch/i386" to "arch/x86" in Documentaion/,
> > > since the directory has changed.
> > >=20
> > > Signed-off-by: Wanlong Gao <wanlong.gao@gmail.com>
> >=20
> > I have queued the Documentation/RCU/NMI-RCU.txt hunk with your
> > Signed-off-by, thank you!
> >=20
> > 							Thanx, Paul
> Hi Paul:
> http://git.kernel.org/?p=3Dlinux/kernel/git/jikos/trivial.git;a=3Dcom=
mitdiff;h=3D25eb650a690b95cb0e2cf0c3b03f4900a59e0135
> jiri had queued these all, will it get a merge failure?

If it does, I will drop mine.

							Thanx, Paul

> Thanks
> >=20
> > > ---
> > >  Documentation/RCU/NMI-RCU.txt             |    4 +-
> > >  Documentation/blockdev/README.DAC960      |    2 +-
> > >  Documentation/blockdev/ramdisk.txt        |    8 +++---
> > >  Documentation/cpu-freq/cpu-drivers.txt    |    2 +-
> > >  Documentation/filesystems/nfs/nfsroot.txt |    2 +-
> > >  Documentation/isdn/README.HiSax           |    2 +-
> > >  Documentation/kbuild/makefiles.txt        |   38 ++++++++++++++-=
-------------
> > >  Documentation/magic-number.txt            |    2 +-
> > >  Documentation/mca.txt                     |    6 ++--
> > >  Documentation/scheduler/sched-arch.txt    |    2 +-
> > >  Documentation/scsi/BusLogic.txt           |    2 +-
> > >  Documentation/serial/computone.txt        |    2 +-
> > >  Documentation/svga.txt                    |    2 +-
> > >  Documentation/zh_CN/magic-number.txt      |    2 +-
> > >  14 files changed, 38 insertions(+), 38 deletions(-)
> <snip patch>
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
