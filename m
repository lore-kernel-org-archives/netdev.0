From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: ixgbe: Unsupported SFP+ modules on 10Gbit/s
	X520-DA2 NIC?
Date: Wed, 18 Jan 2012 21:00:38 +0100
Message-ID: <1326916838.2795.11.camel@probook>
References: <1326886258.19261.25.camel@probook>
	<20120118091351.000052fc@unknown>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120118091351.000052fc@unknown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2012-01-18 at 09:13 -0800, Jesse Brandeburg wrote:
> On Wed, 18 Jan 2012 03:30:58 -0800
> Jesper Dangaard Brouer <hawk@comx.dk> wrote:
>
> > I just bought three 10Gbit/s X520-DA2 NICs (82599 based) for
> > production usage, but I cannot get them to accept any of my 10Gbit/s
> > SFP+ modules (4 different tried). According to the documentation I can
> > find, the X520-DA2 NIC should support fiber optics SFP+ modules.
>
> For X520 adapters, the documentation[1] states that which SFP+
> adapters are/are not supported.  Direct attach cables are also
> supported.
> 
> [1] http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm

They only support two fiber optics SFP+ module!!! ... sorry but that
sucks :-(

Does anybody know why they can only support these two SFP+ modules?
My other 82599 NICs have been running fine with other SFP+ modules.
Is there a technical reason?


> > The SFP+ modules does work in another 82599 based NIC in the same
> > machine (engineering sample from PJ).
> 
> Sorry, can't help you with that one, those samples are different
> hardware.

I fully understand, you cannot support these engineering samples.

Do Intel have another model of NICs, that support more SFP+ modules?
Perhaps the x540 based one?
(I would like support for a 20Km SFP+)

Thanks for your answer, Jesse :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
