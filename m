From: David Miller <davem@davemloft.net>
Subject: Re: e100 REGRESSION in 2.6.32
Date: Wed, 16 Dec 2009 11:11:16 -0800 (PST)
Message-ID: <20091216.111116.58695691.davem@davemloft.net>
References: <Pine.LNX.4.44L0.0912151712560.2643-100000@iolanthe.rowland.org>
	<alpine.WNT.2.00.0912160938450.5316@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, stern@rowland.harvard.edu,
	jeffrey.t.kirsher@intel.com, roger.oksanen@cs.helsinki.fi
To: jesse.brandeburg@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.0912160938450.5316@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Wed, 16 Dec 2009 10:21:31 -0800 (Pacific Standard Time)

> copied the netdev mailing list.  Alan thanks for the report, I wonder if 
> you can revert 98468efddb101f8a29af974101c17ba513b07be1 and see if that 
> fixes it?
> 
> Roger on the To: line made that change, which may have broken e100 for 
> your system.

Better figure out if that commit is the culprit soon as I just
submitted it to -stable last night.

------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
