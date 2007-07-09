From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Mon, 9 Jul 2007 11:46:49 -0700
Message-ID: <20070709114649.00ffd7cc@freepuppy.rosehill.hemminger.net>
References: <46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
	<20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com>
	<468D8B32.9020305@garzik.org> <468EDAF9.3020606@intel.com>
	<20070707190431.GA26341@electric-eye.fr.zoreil.com>
	<46900B83.1060902@intel.com>
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
	<469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
	<46914382.8090801@linux.intel.com> <469280F5.8000909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andy@sc8-sf-spam2.sourceforge.net,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Gospodarek <andy@greyhouse.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <469280F5.8000909@garzik.org>
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

Let me ask a different question. Why do we have some many user reported
problems with network drivers, not just the E1000's?

Is it lack of specifications? test infrastructure?
Or as I suspect lots of it has to with the myriad of chip revisions, including
cases where designs get reworked by OEM's.

If the problem were more understood, then the community would have more confidence
with new drivers and other changes.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
