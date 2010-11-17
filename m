From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 15:54:47 +0800
Message-ID: <AANLkTimi1AhXnqv8991Y3=HwoYwvYxEbPd0LroGouZp9@mail.gmail.com>
References: <20101110.102129.112602843.davem@davemloft.net>
 <1289414024.2469.20.camel@edumazet-laptop> <20101110.103807.39173013.davem@davemloft.net>
 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
 <1289915053.5372.183.camel@edumazet-laptop> <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
 <1289925055.5372.484.camel@edumazet-laptop> <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
 <1289980137.2732.280.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mjt@tls.msk.ru,
	davem@davemloft.net, drosenberg@vsecurity.com, hagen@jauu.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40976 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759869Ab0KQHzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 02:55:09 -0500
Received: by bwz15 with SMTP id 15so1282243bwz.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 23:55:08 -0800 (PST)
In-Reply-To: <1289980137.2732.280.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 17, 2010 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Please repost it when Changli patch is accepted by David
> (if accepted :)), to get rid of the "+ 1"
>

Oh. No need, if David accepts this patch first, otherwise, there is
just some offset, and patch can handle it. :)


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
