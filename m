From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] fq_codel: add per queue memory limit
Date: Wed, 08 Jun 2016 15:28:31 -0700
Message-ID: <1465424911.7945.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464791011.5939.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160608083320.7d950b9a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33879 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbcFHW2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:28:33 -0400
Received: by mail-pa0-f52.google.com with SMTP id bz2so6312004pad.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 15:28:32 -0700 (PDT)
In-Reply-To: <20160608083320.7d950b9a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-08 at 08:33 -0700, Stephen Hemminger wrote:

> Applied but I had to fix a couple of conflicts because recent checkpatch cleanup
> of tc files.

Thanks Stephen, this looks good to me.
