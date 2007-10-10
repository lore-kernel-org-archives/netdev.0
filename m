From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 18:02:11 +0200
Message-ID: <20071010160211.GA14239@one.firstfloor.org>
References: <20071010.034446.85819294.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC32903C0883E@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	jeff@garzik.org, kaber@trash.net, netdev@vger.kernel.org,
	rdreier@cisco.com, mchan@broadcom.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, gaagaan@gmail.com, andi@firstfloor.org,
	general@lists.openfabrics.org, jagana@us.ibm.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903C0883E@orsmsx414.amr.corp.intel.com>
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

> We've done similar testing with ixgbe to push maximum descriptor counts,
> and we lost performance very quickly in the same range you're quoting on
> NIU.

Did you try it with WC writes to the ring or CLFLUSH?

-Andi
