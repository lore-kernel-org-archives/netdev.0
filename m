From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] Enable tx timestamping on loopback and dummy
Date: Mon, 13 Mar 2017 11:40:06 +0100
Message-ID: <20170313104006.GC1875@localhost.localdomain>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
 <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
 <20170312163000.GA1649@localhost.localdomain>
 <20170312215231.GA10928@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ezequiel Lara Gomez <ezegomez@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34242 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752235AbdCMKkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 06:40:11 -0400
Received: by mail-wm0-f48.google.com with SMTP id 196so7352511wmm.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 03:40:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170312215231.GA10928@u480fcf44e5b8574c5490.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 09:52:32PM +0000, Ezequiel Lara Gomez wrote:
> 
> From f3483202625648be728df39622360508f2fb03e1 Mon Sep 17 00:00:00 2001
> From: Ezequiel Lara Gomez <ezegomez@amazon.com>
> Date: Sat, 11 Mar 2017 20:06:54 +0000
> Subject: [PATCH v3] Enable tx timestamping on loopback and dummy
> 
> This enables testing of SO_TIMESTAMPING options by targetting localhost
> addresses.

Yes, we can see from the patch that this enables the transmit
SO_TIMESTAMPING option, but why is this important?  Proper changelog
messages always tell WHY.

Thanks,
Richard
