From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Thu, 23 Aug 2007 18:41:00 -0400
Message-ID: <1187908860.4279.39.camel@localhost>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<1187907903.4279.28.camel@localhost> <46CE0BA1.60206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	johnpol@2ka.mipt.ru, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46CE0BA1.60206@hp.com>
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

On Thu, 2007-23-08 at 15:35 -0700, Rick Jones wrote:
> jamal wrote:
> > [TSO already passed - iirc, it has been
> > demostranted to really not add much to throughput (cant improve much
> > over closeness to wire speed) but improve CPU utilization].
> 
> In the one gig space sure, but in the 10 Gig space, TSO on/off does make a 
> difference for throughput.

I am still so 1Gige;-> I stand corrected again ;->

cheers,
jamal
