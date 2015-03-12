From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: expose RFC4191 route preference via rtnetlink
Date: Wed, 11 Mar 2015 23:28:27 -0400 (EDT)
Message-ID: <20150311.232827.1190221051305922257.davem@davemloft.net>
References: <20150310160423.GC2016@nanopsycho.orion>
	<1426084761-3303-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, kuznet@ms2.inr.ac.ru, jiri@resnulli.us
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426084761-3303-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Wed, 11 Mar 2015 15:39:21 +0100

> This makes it possible to retain the route preference when RAs are handled in
> userspace.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> ---
> Changes since v1:
>   - In case an invalid value is specified treat it as ICMPV6_ROUTER_PREF_MEDIUM

Applied, thanks.
