From: Sanjoy Mahajan <sanjoy@MIT.EDU>
Subject: Re: e1000e fails after several S3 resumes (2.6.26
	Debian, TP T60)
Date: Tue, 28 Oct 2008 16:18:48 -0400
Message-ID: <E1Kuv1c-00033M-Ia@approx.mit.edu>
References: <F169D4F5E1F1974DBFAFABF47F60C10A069DFFA0@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	NetDEV list <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: Your message of "Fri, 24 Oct 2008 09:22:58 PDT."
	<F169D4F5E1F1974DBFAFABF47F60C10A069DFFA0@orsmsx507.amr.corp.intel.com>
	(sfid-20081024_142044_698098_A035A635)
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> I think you should definitely try 2.6.27.y, the e1000e versions in the
> kernel are different than what is in ubuntu at least, so not sure if
> that applies to debian.

I'm running 2.6.27.4, and I haven't seen the e1000e problem yet.  But it
happens quite often with wlan0 (iwl3945), whereupon unloading and
loading the module fixes it.

Is there an analogue of ethtool for wireless cards (for debugging and
resetting a la 'ethtool -r eth0'?  Other than the tcpdump, what
debugging information should I collect for iwl3945?  And who should I
add/remove from the CC before sending it out?

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
