From: Jeremy Harris <jgh@redhat.com>
Subject: Re: What are "forward retransmits"?
Date: Wed, 12 Apr 2017 15:05:06 +0100
Message-ID: <2493345a-c43a-034d-ced2-39cfc7943466@redhat.com>
References: <CAAPSPUuZNbmA=Nt2bWat-f0ka1YtodCFg_nZSRrzGzR5TV+v9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Itai Fiat Gecht <itaifg@infinidat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46720 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753286AbdDLOFK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:05:10 -0400
In-Reply-To: <CAAPSPUuZNbmA=Nt2bWat-f0ka1YtodCFg_nZSRrzGzR5TV+v9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/17 08:34, Itai Fiat Gecht wrote:
> What are the "forward retransmits" shown by netstat?

Allegedly, rfc 3517 section 4, NextSeg() rule (3).
-- 
Cheers,
  Jeremy
