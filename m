From: "Woodruff, Robert J" <robert.j.woodruff@intel.com>
Subject: RE: Re: [PATCH][v5][0/24] Latest IB patch queue
Date: Tue, 4 Jan 2005 09:58:59 -0800
Message-ID: <1AC79F16F5C5284499BB9591B33D6F00032CA55B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
To: "Roland Dreier" <roland@topspin.com>,
	"Karen Shaeffer" <shaeffer@neuralscape.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

=20

    Karen> I am interested in Infiniband with x86_64 Opterons.

Roland>OK, the current code should work well for you -- x86_64 is
probably
Roland>the most-tested architecture.

I have tested on X86_64 EM64T systems. I have a 4 node cluster that I
ran
some MPI tests on top of IpoIB over the holidays and it ran without=20
any problems. I know that others have also tested on x86_64 Opteron,=20
so it should work fine for that arch.=20

woody
