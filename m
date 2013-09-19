From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source
 through dts file
Date: Thu, 19 Sep 2013 19:12:40 +0200
Message-ID: <20130919171240.GA4542@netboy>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
 <5239CA4F.9000600@freescale.com>
 <5239D74F.5030801@skitlab.ru>
 <523B268A.2010805@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
	netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:43331 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab3ISRMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 13:12:52 -0400
Received: by mail-wi0-f171.google.com with SMTP id hm2so8291037wib.16
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 10:12:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <523B268A.2010805@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 19, 2013 at 07:30:02PM +0300, Claudiu Manoil wrote:
> 
> If you ask me, updates for the device trees of several powerpc
> boards, like the 83xx series (as this patch implies), should be
> discussed and agreed upon on the powerpc list (linuxppc-dev@lists.ozlabs.org),
> where these kind of changes are usually being discussed with people more
> knowledgeable in device tree bindings and the powerpc/83xx hardware.

Yes, and also CC the devicetree list. The original device tree
attributes for the gianfar eTSEC timer functions were reviewed on
all three lists.

Thanks,
Richard
