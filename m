From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPSEC maintainership...
Date: Wed, 17 Oct 2012 11:13:02 +0200
Message-ID: <20121017091301.GA23566@secunet.com>
References: <20121015.133833.2211899390966002142.davem@davemloft.net>
 <20121016061154.GF21577@secunet.com>
 <20121016.021435.220828722592000976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52834 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756347Ab2JQJNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 05:13:05 -0400
Content-Disposition: inline
In-Reply-To: <20121016.021435.220828722592000976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 02:14:35AM -0400, David Miller wrote:
> 
> If you want you can maintainer an IPSEC GIT tree, where you apply any
> submitted IPSEC changes.

I've set up two git tries at kernel.org, an 'ipsec' tree that tracks the
net tree and an 'ipsec-next' tree that tracks the net-next tree.

They are located at

git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git
git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git

Once the workflow for IPsec patches is established, I'll ask for
linux-next inclusion of the ipsec-next tree to get early stage
testing of the IPsec changes.

Regarding my own IPsec patches, I'll continue to send them to netdev
for review with the remark that I'll apply them to the appropriate
tree if nobody has objections.
