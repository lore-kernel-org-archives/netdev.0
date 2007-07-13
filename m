From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Fri, 13 Jul 2007 18:08:42 -0400
Message-ID: <4697F7EA.9050101@garzik.org>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com>
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
	<469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
	<46914382.8090801@linux.intel.com>
	<469280F5.8000909@garzik.org> <46929EBB.3000809@intel.com>
	<4692B611.1050603@garzik.org> <4697F27F.6060107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4697F27F.6060107@intel.com>
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

Kok, Auke wrote:
> Sorry for not replying to this earlier (I was on vacation for 2 days). 
> We had some internal discussions and all the noses appear to be facing 
> in the proper direction. I'm very happy with this and it will be my 
> highest priority to make this work. I will attempt to get a quick start 
> on this and come with a start point driver as soon as I can. Thanks to 
> everyones who commented!

Sounds good to me.  My only further comment would be to agree and 
encourage posting of quick-start soon.  Don't worry about much beyond 
"it works" tests before posting the first public version.  We'll 
inevitably need a couple more minor revisions before merging, as with 
all new drivers.

We all seem to be going in the right direction, so the process should 
not take months.  I'll make it a priority to review each revision as 
soon as possible.

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
