From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [ofa-general] RE: parallel networking
Date: Mon, 8 Oct 2007 15:35:53 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903BC14B3@orsmsx414.amr.corp.intel.com>
References: <470A3D24.3050803@garzik.org><20071008.141154.107706003.davem@davemloft.net><1191882618.4373.99.camel@localhost>
	<20071008.153353.58431888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	jeff@garzik.org, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, randy.dunlap@oracle.com,
	gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	mingo@elte.hu, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: "David Miller" <davem@davemloft.net>,
	<hadi@cyberus.ca>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <20071008.153353.58431888.davem@davemloft.net>
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

> Multiply whatever effect you think you might be able to=20
> measure due to that on your 2 or 4 way system, and multiple=20
> it up to 64 cpus or so for machines I am using.  This is=20
> where machines are going, and is going to become the norm.

That along with speeds going to 10 GbE with multiple Tx/Rx queues (with
40 and 100 GbE under discussion now), where multiple CPU's hitting the
driver are needed to push line rate without cratering the entire
machine.

-PJ Waskiewicz
