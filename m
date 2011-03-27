From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211:: fix possible NULL pointer dereference
Date: Sun, 27 Mar 2011 11:18:27 +0200
Message-ID: <1301217507.3826.4.camel@jlt3.sipsolutions.net>
References: <1301164015-7978-1-git-send-email-mk@lab.zgora.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <mk@lab.zgora.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301164015-7978-1-git-send-email-mk@lab.zgora.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-03-26 at 19:26 +0100, Mariusz Kozlowski wrote:
> In cfg80211_inform_bss_frame() wiphy is first dereferenced on privsz
> initialisation and then it is checked for NULL. This patch fixes that.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

Thanks!

johannes
