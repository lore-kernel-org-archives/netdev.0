From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] net: stmmac: fix stmmac_pci_probe failed when
 CONFIG_HAVE_CLK is selected
Date: Fri, 26 Sep 2014 12:12:05 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7F4A0D@PGSMSX102.gar.corp.intel.com>
References: <1411043650-31712-1-git-send-email-hock.leong.kweh@intel.com>
 <20140922.141921.577008114679288180.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C2B7EAE19@PGSMSX102.gar.corp.intel.com>
 <54210EC1.9070507@st.com>
 <F54AEECA5E2B9541821D670476DAE19C2B7EAF23@PGSMSX102.gar.corp.intel.com>
 <54226020.50008@st.com>
 <F54AEECA5E2B9541821D670476DAE19C2B7EB35E@PGSMSX102.gar.corp.intel.com>
 <54255692.8020402@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"wens@csie.org" <wens@csie.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	"tobias.johannes.klausmann@mni.thm.de"
	<tobias.johannes.klausmann@mni.thm.de>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4128 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753973AbaIZMMM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 08:12:12 -0400
In-Reply-To: <54255692.8020402@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> Sent: Friday, September 26, 2014 8:06 PM
> > > From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> > > Sent: Wednesday, September 24, 2014 2:10 PM
> 
> I just meant that if no clock is passed then the probe doesn't fail and we can
> keep a dev_warn. Pls surround the code with a comment and repost the
> patch. Let me know and sorry for the delay on replying.
> 
> peppe
> 

Now I got you. Okay, will do that and send out the V2 patch. Thanks.
