From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 19:54:23 -0700
Message-ID: <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426114608.11398.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426125194.11398.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.215553.1544350193194225837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33820 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbbCLCyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 22:54:25 -0400
Received: by iecsl2 with SMTP id sl2so11088569iec.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 19:54:25 -0700 (PDT)
In-Reply-To: <20150311.215553.1544350193194225837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 21:55 -0400, David Miller wrote:

> Oh, even better, I'll push this one actually.
> 

I'll send an update, because I broke the build when CONFIG_NET_NS=n

Or maybe we should adapt/push Eric patch 2/8 (net: Introduce
possible_net_t)

Eric, do you mind if I respin your patch, or do you prefer to do this
yourself ?
