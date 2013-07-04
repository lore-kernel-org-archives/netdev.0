From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Thu, 04 Jul 2013 08:08:14 -0700
Message-ID: <1372950494.4979.97.camel@edumazet-glaptop>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	 <1372799622.4979.22.camel@edumazet-glaptop>
	 <CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	 <CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fernando Soto <fernando.soto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:60282 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab3GDPIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 11:08:16 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so1393697pad.18
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 08:08:15 -0700 (PDT)
In-Reply-To: <CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-04 at 08:21 -0400, Fernando Soto wrote:
> Hi Eric,
> 
> Unfortunately the issue is still reproducible after the patch was
> applied. Iperf tests were running for almost 24h when it happened:

Well, 3.5 is not a stable kernel, did you try a recent version ?
