From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1 net-next] cfg80211: fix set but not used warning in
 nl80211_channel_switch()
Date: Wed, 29 Oct 2014 17:04:36 +0100
Message-ID: <1414598676.1827.26.camel@jlt4.sipsolutions.net>
References: <1414252655-20506-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414252655-20506-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-10-25 at 17:57 +0200, Fabian Frederick wrote:
> radar_detect_width is unused since commit 97dc94f1d933
> ("cfg80211: remove channel_switch combination check")

Applied, thanks.

johannes
