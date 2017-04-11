From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] cfg80211: Fix array-bounds warning in fragment copy
Date: Tue, 11 Apr 2017 07:16:46 +0200
Message-ID: <1491887806.28432.11.camel@sipsolutions.net>
References: <20170327195822.123034-1-mka@chromium.org>
         <20170410213604.GB28657@google.com> (sfid-20170410_233606_956258_6976A116)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410213604.GB28657@google.com> (sfid-20170410_233606_956258_6976A116)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-10 at 14:36 -0700, Matthias Kaehlcke wrote:
> Ping, any feedback on this patch?

You didn't cc linux-wireless, so it fell through the cracks ... I'll
try to remember it when I merge later.

johannes
