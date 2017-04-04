From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] i40e: limit client interface to X722 hardware
Date: Tue, 4 Apr 2017 19:56:58 +0300
Message-ID: <CAJ3xEMjvmXTAyLP2-BwHRj59uQeCNXA7XSX7kTA=8TmwwmzRkw@mail.gmail.com>
References: <20170404143446.16359-1-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35115 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754569AbdDDQ47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 12:56:59 -0400
Received: by mail-oi0-f52.google.com with SMTP id f193so170271854oib.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 09:56:59 -0700 (PDT)
In-Reply-To: <20170404143446.16359-1-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 5:34 PM, Stefan Assmann <sassmann@kpanic.de> wrote:
> The client interface is meant for X722 iWARP support. Modprobing i40iw
> on systems with X710/XL710 NICs currently may crash the system.

just curious may or crash? and why?
