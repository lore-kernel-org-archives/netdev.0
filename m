From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: i217-LM boot wreckage
Date: Fri, 21 Mar 2014 23:01:11 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403212256540.18573@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
	<alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
	<D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CF4AB@ORSMSX101.amr.corp.intel.com>
	<alpine.DEB.2.02.1403211657110.18573@ionos.tec.linutronix.de>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CF6D9@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>
To: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <2B0E3F215D1AB84DA946C8BEE234CCC9370CF6D9@ORSMSX101.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 21 Mar 2014, Ertman, DavidX M wrote:

> I have discovered the cause of this issue.  It is related to the
> change in the application of a Si errata workaround.
> 
> I will be working on grok'ing the total impact of this issue and
> writing up the patch over the weekend and will have something pushed
> into our internal queue early next week.

Take your time and don't spoil your weekend!

It's not a show stopper, as we know how to work around the issue.

If you need testing of some early patch or help with gathering
information, let me know. We have 4 reproducer systems handy.

Thanks,

	tglx

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
