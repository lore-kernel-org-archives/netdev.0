From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: e1000e: repeated eth0: Error reading PHY register
Date: Wed, 25 Jan 2012 11:16:17 -0800
Message-ID: <20120125191616.GJ21370@hexapodia.org>
References: <20120125092101.GA10626@hexapodia.org>
	<804857E1F29AAC47BF68C404FC60A1842437C3@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1842437C3@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2012 at 05:00:29PM +0000, Allan, Bruce W wrote:
> >On my Thinkpad X201s running 3.3-rc1 I'm seeing bursts of these:
> >
> >[ 1270.207370] e1000e 0000:00:19.0: eth0: Error reading PHY register
> 
> Please file a bug with this information at
> http://sourceforge.net/tracker/?group_id=42302&atid=447449

Man sourceforge sure has jumped the shark; their signup form requires
"job title" and "company size".  I wonder how many other CEOs of 20,000+
employee companies bother to report ethernet driver bugs.

And we don't have "bugs", we have "artifacts".  Sigh.

Anyways, here you go:
https://sourceforge.net/tracker/?func=detail&aid=3479714&group_id=42302&atid=447449

-andy

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
