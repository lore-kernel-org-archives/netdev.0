From: Mark McLoughlin <markmc@redhat.com>
Subject: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 18:29:18 +0100
Message-ID: <1183138159.17243.16.camel@blaa>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GViD+44yIi6exKAyb0fl"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
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


--=-GViD+44yIi6exKAyb0fl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Auke,
	I understand there is some delay in getting e1000-7.5.5 into the
upstream kernel given the major re-working of the chipset specific
parts.

	I wonder would it be feasible in the meantime to backport the ich9
support and push it upstream?

	A first-cut at the backport is attached. Note, this patch applies
against latest netdev-2.6-git, but I haven't actually tested this
version of the patch beyond compiling. A similar patch against 2.6.18
worked fine with some light testing.

Thanks,
Mark.

--=-GViD+44yIi6exKAyb0fl
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--=-GViD+44yIi6exKAyb0fl
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--=-GViD+44yIi6exKAyb0fl--
