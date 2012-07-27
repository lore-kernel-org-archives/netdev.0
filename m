From: Rostislav Lisovy <lisovy@gmail.com>
Subject: Re: [PATCH iproute2 v2 0/3] CAN Filter/Classifier
Date: Fri, 27 Jul 2012 16:09:25 +0200
Message-ID: <1343398165.12164.3.camel@lolumad>
References: <1343383363-6174-1-git-send-email-mkl@pengutronix.de>
	 <50129E17.7030602@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54305 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab2G0OJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 10:09:29 -0400
In-Reply-To: <50129E17.7030602@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 15:56 +0200, Oliver Hartkopp wrote: 
> On 27.07.2012 12:02, Marc Kleine-Budde wrote:
> 
> > I'm reposting Rostislav's iproute2 patches, as Stephen requested,
> > during the v3.6 merge window with the corresponding kernel patches
> > already applied.
> 
> 

> Btw. i think these patches address the original implementation from Rostislav
> using the CAN classifier. The review lead to a completely new implementation
> using ematch. Therefore this patch series is outdated AFAICS.
> 
> @Rostislav: Am i correct here?

Hello Oliver;
You are right -- these are the patches for the old "standalone can
filter/classifier" implementation.
I will send correct patches hopefully on Monday/Tuesday.

Regards;
Rostislav
