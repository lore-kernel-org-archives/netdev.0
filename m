From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v2 1/2] realtek: convert to per-chip mask
Date: Tue, 23 Jul 2013 23:03:45 +0200
Message-ID: <1969296.8vWT4XT66S@al>
References: <3162188.mmLmSZRt9A@al> <1602191.cqZWCGFrek@al> <20130723202437.GC31567@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:49293 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933187Ab3GWVDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 17:03:49 -0400
Received: by mail-wg0-f47.google.com with SMTP id j13so2678473wgh.14
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 14:03:48 -0700 (PDT)
In-Reply-To: <20130723202437.GC31567@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 July 2013 22:24:37 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> [...]
> > +	[RTL8100E1] = "RTL-8100E(1)",
> > +	[RTL8100E2] = "RTL-8100E(2)",
> 
> Tab after equal may be.
Originally I had [NAME <tab(s)>] = ..., but then checkpatch complained. I will 
fix it up.

> The "RTL-" prefix string could be shared.
Good point, I will also fix.

Regards,
Peter
