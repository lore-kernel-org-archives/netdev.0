From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [ofa-general] RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 24 Sep 2007 17:31:46 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903A51586@orsmsx414.amr.corp.intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com><20070916.161748.48388692.davem@davemloft.net><1189988958.4230.55.camel@localhost><1190569987.4256.52.camel@localhost><1190570205.4256.56.camel@localhost><D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com><1190674298.4264.24.camel@localhost><D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com><1190677099.4264.37.camel@localhost><D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
	<20070924171411.36494656@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, jeff@garzik.org, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, hadi@cyberus.ca, kaber@trash.net,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	mcarlson@broadcom.com, sri@us.ibm.com, David Miller <davem@davemloft.net>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070924171411.36494656@freepuppy.rosehill>
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

> > I really just need to put my nose to the grindstone and get the=20
> > patches together and to the list...stay tuned.
> >=20
> > Thanks,
> > -PJ Waskiewicz
> > -
>=20
>=20
> Since we are redoing this, is there any way to make the whole=20
> TX path more lockless?  The existing model seems to be more=20
> of a monitor than a real locking model.

That seems quite reasonable.  I will certainly see what I can do.

Thanks Stephen,

-PJ Waskiewicz
