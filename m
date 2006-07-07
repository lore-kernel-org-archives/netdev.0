From: David Miller <davem@davemloft.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 16:59:33 -0700 (PDT)
Message-ID: <20060707.165933.35333449.davem@davemloft.net>
References: <44AE15C3.8050900@trash.net>
	<44AEA462.1080505@candelatech.com>
	<44AEBCE7.2030203@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, tgraf@suug.ch,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2454
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932418AbWGGX7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 19:59:04 -0400
To: kaber@trash.net
In-Reply-To: <44AEBCE7.2030203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 07 Jul 2006 21:58:31 +0200

> My patches introduced a bug when dumping tables which could lead to
> incorrect routes beeing dumped. A second bug (that already existed)
> makes the kernel fail when dumping more rules than fit in a skb.
> I think I've already seen the patch to address the second problem
> a short time ago sent by someone else. Anyway, this patch should
> fix both.

Nice work Patrick.

You guys have a lot of time to flesh out any remaining issues and
failures, and then submit this for 2.6.19

Thanks again.
