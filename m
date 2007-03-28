From: James Morris <jmorris@namei.org>
Subject: Re: LSPP kernels (was Re: [PATCH]: SAD sometimes has double SAs).
Date: Wed, 28 Mar 2007 13:11:07 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703281306560.4569@d.namei>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
 <1174944899.17953.20.camel@localhost.localdomain>  <20070326.144843.72708308.davem@davemloft.net>
  <1174957467.3085.461.camel@faith.austin.ibm.com>
 <1175094915.3085.503.camel@faith.austin.ibm.com>  <Line.LNX.4.64.0703281213060.2266@d.namei>
 <1175100540.13618.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joy Latten <latten@austin.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Steve G <linux_4ever@yahoo.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:53725 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964780AbXC1RLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 13:11:11 -0400
In-Reply-To: <1175100540.13618.67.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Mar 2007, Eric Paris wrote:

> It is definitely NOT a shortcut into RHEL.

Ok, that was a poor choice of words on my part.

> I don't want to give the impression that upstream is not coming first.
> All the work is being done upstream either on netdev or linux-audit and
> then I pull it back into this LSPP kernel she talked about so that
> people interested primarily in the testing necessary to meet that
> particular government standard have a neat tidy little prebuild rpm to
> work with.  Eventually all of these will show up in RHEL, but not until
> all of the patches i'm dealing with are upstream.

It seems my understanding wasn't clear on the overall workflow.  If the 
consensus is to stay with this scheme, then please disregard my previous 
post.


-- 
James Morris
<jmorris@namei.org>
