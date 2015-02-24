From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: calls nl80211_exit on error
Date: Tue, 24 Feb 2015 11:50:44 +0100
Message-ID: <1424775044.2192.30.camel@sipsolutions.net>
References: <1422410606-6781-1-git-send-email-junjie_mao@yeah.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Junjie Mao <junjie_mao@yeah.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422410606-6781-1-git-send-email-junjie_mao@yeah.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-28 at 10:03 +0800, Junjie Mao wrote:
> nl80211_exit should be called in cfg80211_init if cfg80211_init succeeds but
> regulatory_init or create_singlethread_workqueue fails.

Applied, thanks.

johannes
