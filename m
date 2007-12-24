From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [IPROUTE2] IPT action compatibility with iptables 1.4.0
Date: Mon, 24 Dec 2007 12:57:32 -0500
Message-ID: <1198519052.4427.22.camel@localhost>
References: <1198515305.4427.12.camel@localhost>
	 <20071224094807.060e604f@deepthought>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:56946 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbXLXR5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 12:57:42 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2818736wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 09:57:42 -0800 (PST)
In-Reply-To: <20071224094807.060e604f@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-24-12 at 09:48 -0800, Stephen Hemminger wrote:
> On Mon, 24 Dec 2007 11:55:05 -0500

> Is this backwards compatible with older kernels?

Yes. 
Denys change adds forward compat (although iptables in 1.4 is not fully
backward compatible).

cheers,
jamal

