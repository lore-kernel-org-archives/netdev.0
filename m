From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: report IFLA_GSO_MAX_SIZE and
 IFLA_GSO_MAX_SEGS
Date: Thu, 18 Aug 2016 14:52:51 -0700
Message-ID: <20160818145251.784f11d5@xeon-e3>
References: <1471469961.29842.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35206 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754580AbcHSDBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 23:01:20 -0400
Received: by mail-pa0-f41.google.com with SMTP id i5so11513551pat.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 20:01:20 -0700 (PDT)
In-Reply-To: <1471469961.29842.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Aug 2016 14:39:21 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> kernel support for these attributes was added in linux-4.6
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>


What about setting them?
