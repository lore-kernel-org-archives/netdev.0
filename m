From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Fix warning for token-ring from sysctl checker
Date: Wed, 14 Nov 2007 08:45:28 -0800
Message-ID: <20071114084528.0f092739.randy.dunlap@oracle.com>
References: <20071113072313.GB16842@lixom.net>
	<20071113.211540.97775009.davem@davemloft.net>
	<m1r6is253v.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, olof@lixom.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:11430 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756698AbXKNQqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 11:46:37 -0500
In-Reply-To: <m1r6is253v.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 08:56:20 -0700 Eric W. Biederman wrote:

> David Miller <davem@davemloft.net> writes:
> 
> > From: Olof Johansson <olof@lixom.net>
> > Date: Tue, 13 Nov 2007 01:23:13 -0600
> >
> >> As seen when booting ppc64_defconfig:
> >> 
> >> sysctl table check failed: /net/token-ring .3.14 procname does not match
> > binary path procname
> >> 
> >> 
> >> Signed-off-by: Olof Johansson <olof@lixom.net>
> >
> > Patch applied, thanks Olof.
> 
> No objections but I think we already have this fixed in the -mm tree.

Yes, I patched it several weeks ago and it's been in -mm for a while
now.  Apparently too long.

---
~Randy
