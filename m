From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Sweep away N/A fw_version
 dustbunnies from the .get_drvinfo routine of a number of drivers
Date: Tue, 22 Nov 2011 16:53:37 -0500 (EST)
Message-ID: <20111122.165337.867376721899719922.davem@davemloft.net>
References: <20111121205405.A0FF1290041F@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, dm@chelsio.com, sbhatewara@vmware.com,
	ron.mercer@qlogic.com, chris.snook@gmail.com, divy@chelsio.com
To: raj@tardy.cup.hp.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20111121205405.A0FF1290041F@tardy>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Mon, 21 Nov 2011 12:54:05 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Per discussion with Ben Hutchings and David Miller, go through and
> remove assignments of "N/A" to fw_version in various drivers'
> .get_drvinfo routines.  While there clean-up some use of bare
> constants and such.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
