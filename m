From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] netvsc: optimize calculation of number of
 slots
Date: Tue, 30 May 2017 10:16:51 -0700
Message-ID: <20170530101651.01222b83@xeon-e3>
References: <20170529183159.22205-1-sthemmin@microsoft.com>
        <20170529.204204.1236270965995441170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36215 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbdE3RQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 13:16:55 -0400
Received: by mail-pf0-f171.google.com with SMTP id m17so77924001pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 10:16:55 -0700 (PDT)
In-Reply-To: <20170529.204204.1236270965995441170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 May 2017 20:42:04 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> Stephen, please provide proper header "[PATCH net-next 0/3] " postings
> with your patch series, so we know at a high level what this patch
> series is doing, how it is doing it, and why it is doing it that
> way.

Sure, these were just misc small cleanups. Prefer to send them out
in small chunks, not mixed with bug fixes and new features.

> I've been quite liberal with your patch postings in the past, hoping
> you would catch on, but now I'm going to simply enforce what I ask
> of every other patch series submitter.

Sorry, thought it was obvious from content.
