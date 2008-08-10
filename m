From: Elad Lahav <elad_lahav@users.sourceforge.net>
Subject: Re: Performance degradration 2.6.25->2.6.26
Date: Sun, 10 Aug 2008 05:05:28 -0400
Message-ID: <489EAF58.7030404@users.sourceforge.net>
References: <489C0F2C.9040101@users.sourceforge.net>
	<alpine.WNT.1.10.0808080906590.5428@jbrandeb-MOBL1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.1.10.0808080906590.5428@jbrandeb-MOBL1.amr.corp.intel.com>
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

By the way, using the 2.6.25 driver under the 2.6.26 kernel does not fix 
the problem, so changes to the driver code are clearly not the culprit.

> e1000 shortlog between those two kernels shows no real changes that could 
> effect performance besides the irq_sem fix.

Elad

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
