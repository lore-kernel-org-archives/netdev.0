From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: pull-request: mac80211 2017-10-16
Date: Tue, 17 Oct 2017 20:21:32 +0200
Message-ID: <CAHmME9qd_m-FDj1E+eiBYWKvnMBvr0tWVcJ4ph2tr=Y1d_tb1g@mail.gmail.com>
References: <20171016134618.30810-1-johannes@sipsolutions.net>
 <CAHmME9rHMMAgJs3uQYpt15V8eh-PjDqioqURA3KPKEhc2a9OEg@mail.gmail.com> <1508219181.10607.45.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40535 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758221AbdJQSVf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:35 -0400
In-Reply-To: <1508219181.10607.45.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 7:46 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> If it's not equal, you execute so much code
> beneath, going to the driver etc., that I'd think this particular time
> is in the noise.

Usually presumptions like this get you in trouble when some crafty
academic has a smart idea about that noise. I'll send a patch.
