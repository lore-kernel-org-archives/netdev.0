From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with latest updates)
Date: Tue, 27 Jun 2006 22:23:43 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606272223110.7158@d.namei>
References: <OF5E332833.A2E43B52-ON8525719B.0009D441-8525719B.000A510A@us.ibm.com>
 <Pine.LNX.4.64.0606272213240.7100@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	George Wilson <gcwilson@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	latten@austin.ibm.com, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:56497 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030444AbWF1CXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 22:23:46 -0400
To: Xiaolan Zhang <cxzhang@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0606272213240.7100@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006, James Morris wrote:

> > I think conceptually this is where it should reside -- auditing system 
> > might need it in the future, for example.
> 
> We can export it then.

To clarify, we can export it if the audit system needs it, in the future.



- James
-- 
James Morris
<jmorris@namei.org>
