From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] ixgbe: fix broken PPTP handling
Date: Tue, 20 Nov 2012 17:56:26 +0000
Message-ID: <20121120175626.26ab6128@pyramind.ukuu.org.uk>
References: <20121120163227.11935.57062.stgit@bob.linux.org.uk>
	<06DFBC1E25D8024DB214DC7F41A3CD34489616B9@ORSMSX101.amr.corp.intel.com>
	<02874ECE860811409154E81DA85FBB583AF32E22@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <02874ECE860811409154E81DA85FBB583AF32E22@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> Specifically, commit 3645adbb "ixgbe: fix uninitialized event.type in ixgbe_ptp_check_pps_event"
> 
> :)
> 
> Sorry I didn't reply directly to your original email with the concern, or CC you. I will do so next time.

No problem - I missed the fact it was fixed with a different
non-overlapped patch.

Alan

------------------------------------------------------------------------------
Monitor your physical, virtual and cloud infrastructure from a single
web console. Get in-depth insight into apps, servers, databases, vmware,
SAP, cloud infrastructure, etc. Download 30-day Free Trial.
Pricing starts from $795 for 25 servers or applications!
http://p.sf.net/sfu/zoho_dev2dev_nov
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
