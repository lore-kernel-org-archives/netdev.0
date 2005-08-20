From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: Re: Page Allocation Failure with e1000 using jumboframe
Date: Sat, 20 Aug 2005 04:46:24 +0300
Message-ID: <200508200446.25149.m.iatrou@freemail.gr>
References: <1124326404.5546.215.camel@localhost.localdomain> <1124470909.5552.11.camel@localhost.localdomain> <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ming Zhang <mingz@ele.uri.edu>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: e1000-devel@lists.sourceforge.net
In-Reply-To: <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Content-Disposition: inline
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

When the date was Friday 19 August 2005 20:33, Jesse Brandeburg wrote:

> PS we have a driver in test that won't do the large contig allocations any
> more.

In fact, I tested a version of these drivers about 3 months ago and not only 
they didn't solve the problem, but the throughput decreased!
Is there a newer version? I would gladly test it...

(previous report)
http://sourceforge.net/mailarchive/forum.php?thread_id=7237829&forum_id=12401

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
