From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH v2 1/2] e1000e: Only disable ASPM on
	82573L devices
Date: Thu, 11 Feb 2010 17:44:06 +0000
Message-ID: <20100211174406.GB32319@srcf.ucam.org>
References: <1265905767-3884-1-git-send-email-mjg@redhat.com>
	<alpine.WNT.2.00.1002110916130.6892@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1002110916130.6892@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Feb 11, 2010 at 09:17:12AM -0800, Brandeburg, Jesse wrote:
> 
> 
> On Thu, 11 Feb 2010, Matthew Garrett wrote:
> 
> > The 82537 errata and comment in e1000e_disable_l1aspm both agree that
> > only 82537L devices are affected. Limit the L1 disable to them.
> 
> Hi Matthew, its a nitpick, but can you please change the part number to 
> the correct one?  it should be s/82537/82573

Whoops! Sorry, I'll do that.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

------------------------------------------------------------------------------
SOLARIS 10 is the OS for Data Centers - provides features such as DTrace,
Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
http://p.sf.net/sfu/solaris-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
