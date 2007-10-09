From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 15:44:39 -0700
Message-ID: <adahckzhprc.fsf@cisco.com>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
	<20071009.135145.95506679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	randy.dunlap@oracle.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.135145.95506679.davem@davemloft.net> (David Miller's
	message of "Tue, 09 Oct 2007 13:51:45 -0700 (PDT)")
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

 > Before you add new entries to your list, how is that ibm driver NAPI
 > conversion coming along? :-)

OK, thanks for the kick in the pants, I have a couple of patches for
net-2.6.24 coming (including an unrelated trivial warning fix for
IPoIB).

 - R.
