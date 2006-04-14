From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 15:52:02 -0700 (PDT)
Message-ID: <20060414.155202.82987818.davem@davemloft.net>
References: <Pine.WNT.4.63.0604141527420.2116@jbrandeb-desk.amr.corp.intel.com>
	<20060414.154240.30125561.davem@davemloft.net>
	<Pine.WNT.4.63.0604141543170.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, herbert@gondor.apana.org.au,
	kernel@linuxace.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57511
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751327AbWDNWwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:52:00 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141543170.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 15:46:31 -0700 (Pacific Daylight Time)

> sure, thats fine, but we just reproduced it in two seperate systems 
> without the e1000 driver loaded, using the instructions as mentioned in a 
> previous email.  We used a 5704 with TSO enabled.

That I didn't notice, thanks for the datapoint.
