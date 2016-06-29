From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 0/4] Mesh mpm fixes and enhancements
Date: Wed, 29 Jun 2016 14:43:19 +1000
Message-ID: <CAGRGNgWgo=TtHkP9qWD=45bSAbEtSsrRCt35AzuPcmjfW4yb5A@mail.gmail.com>
References: <20160628111307.8784-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yaniv Machani <yanivma@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628111307.8784-1-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yaniv,

On Tue, Jun 28, 2016 at 9:13 PM, Yaniv Machani <yanivma@ti.com> wrote:
> This patch set is addressing some issues found in the current 802.11s implementation,
> specifically when using hostap mpm.
> It's aligning the beacon format and handling some corner cases.
>
> Maital Hahn (2):
>   mac80211: mesh: flush stations before beacons are stopped
>   mac80211/cfg: mesh: fix healing time when a mesh peer is disconnecting
>
> Meirav Kama (2):
>   mac80211: mesh: fixed HT ies in beacon template
>   mac80211: sta_info: max_peers reached falsely

Patches that you send must be signed off by you, not ack'd by you.

I.e.

From: Random Developer <random.developer@company.com>

.....

Signed-off-by: Random Developer <random.developer@company.com>
Signed-off-by: Patch Sender <patch.sender@company.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
