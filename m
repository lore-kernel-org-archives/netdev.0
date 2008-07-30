From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Wed, 30 Jul 2008 11:37:28 +0000
Message-ID: <20080730113727.GB6362@ff.dom.local>
References: <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725.044928.261427957.davem@davemloft.net> <488B24E6.4020003@trash.net> <20080726141844.GB2873@ami.dom.local> <489046C3.5030208@trash.net> <20080730111915.GA6362@ff.dom.local> <48904EB2.8060402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:37668 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYG3LcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 07:32:17 -0400
Received: by nf-out-0910.google.com with SMTP id d3so98021nfc.21
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 04:32:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48904EB2.8060402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 01:21:22PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
>> I thought it needs to wait for your audit. (Considering current
>> state of NET_XMIT statuses it's simple and reliable.) Otherwise
>> I'd prefer nice methods too.
>>   
> Well, the problems are already clear, someone just needs to fix them :)
> I won't be able to do this until next week.

...alas to me the solution looks less clear...

Jarek P.
