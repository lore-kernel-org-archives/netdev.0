From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Sun, 02 Jun 2013 07:24:15 -0700
Message-ID: <1370183055.24311.35.camel@edumazet-glaptop>
References: <87zjx9pf13.fsf@nemi.mork.no>
	 <1365431422.3887.10.camel@edumazet-glaptop> <87li8tyrzs.fsf@nemi.mork.no>
	 <1365434301.3887.14.camel@edumazet-glaptop> <87k3mcizlm.fsf@nemi.mork.no>
	 <1370182956.24311.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:37309 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3FBOYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 10:24:17 -0400
Received: by mail-pd0-f180.google.com with SMTP id 14so4438692pdc.25
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 07:24:17 -0700 (PDT)
In-Reply-To: <1370182956.24311.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 07:22 -0700, Eric Dumazet wrote:
> F-RTO code was replaced by Yuching Cheng, and it might very well have
> solved these issues.

Sorry for the misspell, its Yuchung, of course.
