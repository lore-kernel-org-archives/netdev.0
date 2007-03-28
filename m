From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Wed, 28 Mar 2007 12:13:12 -0700 (PDT)
Message-ID: <20070328.121312.26277546.davem@davemloft.net>
References: <20070326.144843.72708308.davem@davemloft.net>
	<1174957467.3085.461.camel@faith.austin.ibm.com>
	<1175094915.3085.503.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965695AbXC1TNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 15:13:13 -0400
In-Reply-To: <1175094915.3085.503.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Wed, 28 Mar 2007 09:15:15 -0600

> Last night I browsed the ipsec-tools code and saw places in
> racoon where improvement would actually fix this
> problem. I am working on a patch and will pursue this 
> on the ipsec-tools mailing list.
> 
> I apologize for any inconvenience. 

No problem, thanks for the update.

> The permission check before flushing does still
> need to be added to kernel. 

Yep, I'll take care of integrating that patch.

Thanks!
