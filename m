From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 15:03:50 -0700
Message-ID: <20070629150350.414553d4.akpm@linux-foundation.org>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
	<46857C08.4030303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Mark McLoughlin <markmc@redhat.com>,
	Jason Lunz <lunz@reflexsecurity.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46857C08.4030303@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 29 Jun 2007 14:39:20 -0700
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> 
> That's why we want to introduce a second e1000 driver (named differently, pick 
> any name) that contains the new code base, side-by-side into the kernel with the 
> current e1000.

Sounds like a reasonable approach to me (it has plenty of precedent).  But
I forget what all the other issues were, so ignore me.

> This new e1000 codebase goes miles and miles beyond what I posted in april/march 
> and what is in -mm.

There are no e1000 changes in -mm (from you), I don't believe.  git-e1000
has been in permadrop mode since 2.6.22-rc1-mm1 due to a huge number of git
rejects/conflicts.

Is git://lost.foo-projects.org/~ahkok/git/netdev-2.6#mm the correct URL?


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
