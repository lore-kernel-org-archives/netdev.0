From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [BUG 2.6.30-rc1] panic when loading oprofile
Date: Wed, 20 May 2009 13:27:20 +0200
Message-ID: <20090520112720.GB8684@one.firstfloor.org>
References: <alpine.WNT.2.00.0905131327430.7052__41366.1100705669$1242253861$gmane$org@jbrandeb-desk1.amr.corp.intel.com>
	<87fxf6pmh5.fsf@basil.nowhere.org>
	<20090516162017.2525511c.akpm@linux-foundation.org>
	<F169D4F5E1F1974DBFAFABF47F60C10A335277B5@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>, "oprofile-list@lists.sourceforge.net"
	<oprofile-list@lists.sourceforge.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <oprofile-list-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A335277B5@orsmsx507.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=oprofile-list>
List-Post: <mailto:oprofile-list@lists.sourceforge.net>
List-Help: <mailto:oprofile-list-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=subscribe>
Errors-To: oprofile-list-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2009 at 12:13:24AM -0700, Brandeburg, Jesse wrote:
> Andrew Morton wrote:
> > On Fri, 15 May 2009 14:41:26 +0200 Andi Kleen <andi@firstfloor.org>
> > wrote:
> >
> > > "Brandeburg, Jesse" <jesse.brandeburg@intel.com> writes:
> > >
> > > Hi Jesse,
> > >
> > > > when starting a profile run on the latest net-next kernel, I'm
> > currently
> > > > trying to reproduce on 2.6.30-rc5 stock.
> > >
> > > Were you able to reproduce it?
> 
> For some reason I can no longer reproduce, I'll add a note to the bug too.

Did you have the nmi watchdog enabled?  Does it tick now?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables 
unlimited royalty-free distribution of the report engine 
for externally facing server and web deployment. 
http://p.sf.net/sfu/businessobjects
