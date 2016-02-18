From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH V6 2/8] test_bitmap: unit tests for lib/bitmap.c
Date: Thu, 18 Feb 2016 19:06:34 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0770588FC6E@SHSMSX103.ccr.corp.intel.com>
References: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
	<1455625964-8943-3-git-send-email-kan.liang@intel.com>
 <20160218.140008.1645431745407584155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bwh@kernel.org" <bwh@kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.c
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33187 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945995AbcBRTNO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:13:14 -0500
In-Reply-To: <20160218.140008.1645431745407584155.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> From: Kan Liang <kan.liang@intel.com>
> Date: Tue, 16 Feb 2016 07:32:38 -0500
> 
> > @@ -43,6 +43,7 @@ obj-$(CONFIG_TEST_USER_COPY) +=
> test_user_copy.o
> >  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
> >  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
> >  obj-$(CONFIG_TEST_PRINTF) += test_printf.o
> > +obj-$(CONFIG_TEST_BITMAP) += test_bitmap.o
>  ...
> >
> > -TEST_PROGS := printf.sh
> > +TEST_PROGS := printf.sh bitmap.sh
> 
> I see neither test_bitmap.c nor bitmap.sh in this patch, perhaps some
> forgotten git add commands?

Oh, Right, Sorry for that.

I will re-send the series with latest bitmap update from David Decotigny.

Thanks,
Kan
