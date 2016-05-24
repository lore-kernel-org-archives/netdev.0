From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH iproute2 v3 1/5] add missing if_macsec.h header from
 kernel
Date: Tue, 24 May 2016 15:10:23 +0200
Message-ID: <20160524131023.GA23050@bistromath.localdomain>
References: <cover.1463585050.git.sd@queasysnail.net>
 <87b1f9795592d29be689943e2b8ec9712bda056b.1463585050.git.sd@queasysnail.net>
 <20160523160720.69bcd2ef@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbcEXNK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 09:10:27 -0400
Content-Disposition: inline
In-Reply-To: <20160523160720.69bcd2ef@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-23, 16:07:20 -0700, Stephen Hemminger wrote:
> On Wed, 18 May 2016 17:35:09 +0200
> Sabrina Dubroca <sd@queasysnail.net> wrote:
> 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Acked-by: Phil Sutter <phil@nwl.cc>
> 
> This header already exists in master branch of iproute2, with current version
> from upstream kernel (with PAD values).

It wasn't when I posted this ;)
Excellent, I'll drop this patch from v4.


Thanks,

-- 
Sabrina
