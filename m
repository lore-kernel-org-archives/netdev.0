From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Add stub for cfg80211_get_station()
Date: Tue, 30 Aug 2016 08:06:40 +0200
Message-ID: <1472537200.4249.5.camel@sipsolutions.net>
References: <20160819200248.8202-1-linus.luessing@c0d3.blue>
         (sfid-20160819_220304_170640_809CF938)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Antonio Quartulli <a@unstable.cc>,
        b.a.t.m.a.n@lists.open-mesh.org
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160819200248.8202-1-linus.luessing@c0d3.blue> (sfid-20160819_220304_170640_809CF938)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-08-19 at 22:02 +0200, Linus Lüssing wrote:
> This allows modules using this function (currently: batman-adv) to
> compile even if cfg80211 is not built at all, thus relaxing
> dependencies.


johannes
