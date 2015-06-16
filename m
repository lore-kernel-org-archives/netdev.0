From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Tue, 16 Jun 2015 16:00:42 -0500
Message-ID: <87twu7id1h.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<20150615.171042.1771913051598016582.davem@davemloft.net>
	<87twu8lcre.fsf@x220.int.ebiederm.org> <20150616103206.GA3882@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, stephen@networkplumber.org,
	jjciarla@raiz.uncu.edu.ar, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, kaber@trash.net,
	kadlec@blackhole.kfki.hu, jhs@mojatatu.com,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50928 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbbFPVGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 17:06:11 -0400
In-Reply-To: <20150616103206.GA3882@salvia> (Pablo Neira Ayuso's message of
	"Tue, 16 Jun 2015 12:32:06 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Mon, Jun 15, 2015 at 07:26:13PM -0500, Eric W. Biederman wrote:
> [...]
>> So what I am in the processes of doing is reviewing and testing
>> the combined set of patches and hopefully I will have something
>> for you soon (tomorrow?).  Unless Pablo has objections.
>
> Please, feel free to take over my patchset and improve it. That has
> consumed part of my weekend and I have several open branches in my
> internal tree that I need to push forward.
>
> So I'd be really happy if you polish them and get this done.
>
> Let me know if I can help in any case.

Will do.  I have found more bugs lurking in your boilter plate changes
that I am comfortable with so I am in the process of refactoring things
a bit more than you did so the sweeping changes are more pedantic
and much less likely to introduce bugs.

Eric
