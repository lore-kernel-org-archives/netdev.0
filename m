From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:45:42 -0700
Message-ID: <4643A096.7000909@goop.org>
References: <464395E5.2090500@goop.org>	<20070510151426.d808384f.akpm@linux-foundation.org>	<46439B19.7010706@goop.org> <20070510.152552.117703057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, herbert@gondor.apana.org.au,
	hch@infradead.org, ak@suse.de, virtualization@lists.osdl.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org, jeff@garzik.org,
	shemminger@linux-foundation.org, rusty@rustcorp.com.au,
	Valdis.Kletnieks@vt.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:51150 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755956AbXEJWpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 18:45:45 -0400
In-Reply-To: <20070510.152552.117703057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I'm not so certain now that we know it's the jiffies wrap point :-)
>
> The fixes in question are attached below and they were posted and
> discussed on netdev:
>   

Yep, this patch gets rid of my spinning thread.  I can't find this patch
or any discussion on marc.info; is there a better netdev list archive?

    J
