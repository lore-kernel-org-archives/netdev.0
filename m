From: James Morris <jmorris@namei.org>
Subject: LSPP kernels (was Re: [PATCH]: SAD sometimes has double SAs).
Date: Wed, 28 Mar 2007 12:20:24 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703281213060.2266@d.namei>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
 <1174944899.17953.20.camel@localhost.localdomain>  <20070326.144843.72708308.davem@davemloft.net>
  <1174957467.3085.461.camel@faith.austin.ibm.com> <1175094915.3085.503.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Eric Paris <eparis@redhat.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Steve G <linux_4ever@yahoo.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, selinux@tycho.nsa.gov
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:34839 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932854AbXC1QU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 12:20:28 -0400
In-Reply-To: <1175094915.3085.503.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Mar 2007, Joy Latten wrote:

> Eric, sorry as I know you already patched lspp kernel
> for testing.

I think it'd be better to have the lspp kernel join the upstream workflow 
process, rather than being a shortcut into RHEL.

Please consider creating an lspp git tree (based off Linus' tree), then 
once patches there are tested and ready to submit upstream, post them here 
or selinux-list, where they can be reviewed and applied to either my or 
DaveM's git tree.

>From there, they'll be picked up in -mm for even wider testing then be 
merged into mainline as appropriate.  Then, they can be incorporated into 
distro devel kernels when they update their kernels, or backported to 
stable distro kernels as already reviewed & tested upstream patches.

If there are any objections, please respond.


- James
-- 
James Morris
<jmorris@namei.org>
