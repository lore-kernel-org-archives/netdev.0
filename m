From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH 0/1] netfilter: xt_condition: add condition target
Date: Thu, 12 Aug 2010 13:14:04 +0300
Message-ID: <1281608044.4440.18.camel@powerslave>
References: <1281595021-24310-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1008121202320.31027@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>,
	"Ylalehto Janne (Nokia-MS/Tampere)" <janne.ylalehto@nokia.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:39215 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932747Ab0HLKPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 06:15:08 -0400
In-Reply-To: <alpine.LSU.2.01.1008121202320.31027@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-12 at 12:10 +0200, ext Jan Engelhardt wrote:
> On Thursday 2010-08-12 08:37, Luciano Coelho wrote:
> >
> >One thing that came to my mind was whether it would make sense to
> >rename this match/target combo to "variable" instead of "condition".
> >To me it makes more sense to call it variable than condition, since
> >I have changed the value from boolean to u32. On the other hand, it
> >could become very confusing because it used to be called condition
> >in its xtables-addons days...
> 
> To improve matters, POSIX has something called "condition variables".
> So oh well let's just leave it as-is :)

:D

Okay, let's keep it like this, I guess it would just complicate things
more if we change it.

-- 
Cheers,
Luca.

