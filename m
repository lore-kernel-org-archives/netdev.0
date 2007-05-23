From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
	(was: e1000:	assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Wed, 23 May 2007 16:34:18 -0700
Message-ID: <20070523233418.GA3391@sequoia.sous-sol.org>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
	<46522E6F.9060600@garzik.org>
	<20070522010137.GC8130@gondor.apana.org.au>
	<465320A6.80706@redhat.com> <4653223D.2010108@intel.com>
	<20070523104711.GA24332@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	Greg KH <greg@kroah.com>, Chuck Ebbert <cebbert@redhat.com>,
	netdev@vger.kernel.org, davej@redhat.com, stable@kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070523104711.GA24332@gondor.apana.org.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Tue, May 22, 2007 at 10:02:53AM -0700, Kok, Auke wrote:
> > 
> > I've posted that before and it's up to the stable team. I think that it's a 
> > seriously toolarge change unless Herbert posts his short version of the fix 
> > for 2.6.21.1. I would be OK with that.
> 
> This patch should work for 2.6.21.

Mind adding an updated changelog and signed-off-by please?

thanks,
-chris

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
