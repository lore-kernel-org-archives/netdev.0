From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 0/3] IPVS: Use CTL_UNNUMBERED
Date: Wed, 14 Nov 2007 13:57:32 -0700
Message-ID: <m1pryczgsj.fsf@ebiederm.dsl.xmission.com>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44922 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbXKNU62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:58:28 -0500
In-Reply-To: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
	(Simon Horman's message of "Wed, 14 Nov 2007 10:06:15 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman <horms@verge.net.au> writes:

> Hi,
>
> this series of three patches, the first of which is by
> Christian Borntraeger, switches IPVS over to use CTL_UNNUMBERED,
> removing a lot of unused cruft.
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks sane to me.

Eric
