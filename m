From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Sun, 23 Sep 2007 17:20:48 -0400
Message-ID: <1190582448.4240.2.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<46F6AE18.7080708@garzik.org> <1190574713.5030.4.camel@localhost>
	<46F6C059.6000600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, Jeff Garzik <jeff@garzik.org>,
	rdreier@cisco.com, mcarlson@broadcom.com,
	general@lists.openfabrics.org, sri@us.ibm.com, jagana@us.ibm.com,
	mchan@broadcom.com, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, David Miller <davem@davemloft.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F6C059.6000600@intel.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-23-09 at 12:36 -0700, Kok, Auke wrote:

> please be reminded that we're going to strip down e1000 and most of the features
> should go into e1000e, which has much less hardware workarounds. I'm still
> reluctant to putting in new stuff in e1000 - I really want to chop it down first ;)

sure - the question then is, will you take those changes if i use
e1000e? theres a few cleanups that have nothing to do with batching;
take a look at the modified e1000 on the git tree.

cheers,
jamal
