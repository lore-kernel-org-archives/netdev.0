From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v3 00/12] IPVS: SIP Persistence Engine
Date: Sat, 2 Oct 2010 12:00:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010021155520.2055@ja.ssi.bg>
References: <20101002023056.536217499@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Patrick McHardy <kaber@trash.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36193 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753593Ab0JBJBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Oct 2010 05:01:03 -0400
In-Reply-To: <20101002023056.536217499@akiko.akashicho.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Sat, 2 Oct 2010, Simon Horman wrote:

> This patch series adds load-balancing of UDP SIP based on Call-ID to
> IPVS as well as a frame-work for extending IPVS to handle alternate
> persistence requirements.
>
> REVISIONS
>
> This is v3 of the patch series with addresses serveral problems
> raised by Julian Anastasov on the lvs-devel mailing list.

 	No other obvious problems in v3 1-12. So,
Acked-by: Julian Anastasov <ja@ssi.bg>

 	May be next days I'll test my changes on top of PE v3

Regards

--
Julian Anastasov <ja@ssi.bg>
