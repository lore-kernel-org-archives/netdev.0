From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 0/6] net-timestamp: new tx tstamps and tcp
Date: Mon, 4 Aug 2014 22:16:43 -0400
Message-ID: <CA+FuTSeeqwOLnz+jW_fsCT9yMFLGQcDH_aEYh54mKBVOaGr7wQ@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:53095 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbaHECRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:17:13 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so306783qab.18
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:17:13 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies for the off-by-one error in the subject of each patch: this
is v5. The changelog does mention that correctly.

If the code needs changes, or if you prefer to merge it together with
documentation + example code, I can also resubmit after the window
reopens for 3.18.

Thanks,

  Willem
