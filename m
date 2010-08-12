From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 0/1] netfilter: xt_condition: add condition target
Date: Thu, 12 Aug 2010 12:10:02 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008121202320.31027@obet.zrqbmnf.qr>
References: <1281595021-24310-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, sameo@linux.intel.com, janne.ylalehto@nokia.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1281595021-24310-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-08-12 08:37, Luciano Coelho wrote:
>
>One thing that came to my mind was whether it would make sense to
>rename this match/target combo to "variable" instead of "condition".
>To me it makes more sense to call it variable than condition, since
>I have changed the value from boolean to u32. On the other hand, it
>could become very confusing because it used to be called condition
>in its xtables-addons days...

To improve matters, POSIX has something called "condition variables".
So oh well let's just leave it as-is :)
