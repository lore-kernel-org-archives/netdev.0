From: "Andrew Victor" <avictor.za@gmail.com>
Subject: Re: [PATCH v2] at91_ether: use netstats in net_device structure
Date: Thu, 8 May 2008 21:50:47 +0200
Message-ID: <cd73a99e0805081250t79d56f86t5cf1e33f8075b345@mail.gmail.com>
References: <4820572E.7010304@teltonika.lt>
	 <200805081740.10061.marc.pignat@hevs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux@maxim.org.za
To: "Marc Pignat" <marc.pignat@hevs.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:7504 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbYEHTus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 15:50:48 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1135529rvb.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 12:50:47 -0700 (PDT)
In-Reply-To: <200805081740.10061.marc.pignat@hevs.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

> Use net_device_stats from net_device structure instead of local.
>
> v2: Removed unused variable 'lp' in at91ether_stats function.
>
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Tested-by: Marc Pignat <marc.pignat@hevs.ch>

Acked-by: Andrew Victor <linux@maxim.org.za>


Regards,
  Andrew Victor
