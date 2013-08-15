From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local addresses
Date: Thu, 15 Aug 2013 06:57:21 +0200
Message-ID: <20130815045701.GA3110@x61s.8.8.8.8>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
 <20130814.125346.585011183381258117.davem@davemloft.net>
 <20130814211658.GA2075@x61s.8.8.8.8>
 <20130814.171825.944941726261089646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:60708 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab3HOExe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 00:53:34 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so124029eak.36
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 21:53:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130814.171825.944941726261089646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Aug 14, 2013 at 05:18:25PM -0700, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Wed, 14 Aug 2013 23:17:01 +0200
> 
> > Ok, please let me know what should I do to submit it properly.
> 
> What you don't understand is that just because patches aren't
> related doesn't mean that their order of application doesn't
> matter.
> 
Ok. I got the information on an other mailinglist that I should
not mix "features" and "fixes" in a single series. Then I just
try to seperate...

My first patch-serie included all patches in a single series.

> So you put all the patches into a full series so that there is no
> ambiguity as to what order the patches are to be applied.
> 
Ok.

> Do not ever seperate patches when you are submitting changes to the
> same exact files at one time.
Ok, I will remember it.

Thanks and apologize for the inconvenience

Regards
Alex
