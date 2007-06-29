From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 17:39:34 -0400
Message-ID: <20070629213933.GA7506@gospo.rdu.redhat.com>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Mark McLoughlin <markmc@redhat.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Jason Lunz <lunz@reflexsecurity.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070629175006.GB3917@falooley.org>
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

On Fri, Jun 29, 2007 at 10:50:07AM -0700, Jason Lunz wrote:
> On Fri, Jun 29, 2007 at 06:29:18PM +0100, Mark McLoughlin wrote:
> > 	I understand there is some delay in getting e1000-7.5.5 into the
> > upstream kernel given the major re-working of the chipset specific
> > parts.
> > 
> > 	I wonder would it be feasible in the meantime to backport the ich9
> > support and push it upstream?
> 
> seconded - this driver reorg has been holding back support for the
> newest e1000 hardware since at least 2.6.20, and I haven't seen any
> indication that the 7.5.5 e1000 driver will even be added to 2.6.23.
> 

I'll ACK this as well.  I'd like to see ich9 support upstream as soon as
possible and I'd rather see it with the old driver than not at all.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
