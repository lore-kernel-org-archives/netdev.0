From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 18/19] mac80211: make ieee80211_new_mesh_header return
 unsigned
Date: Thu, 24 Sep 2015 16:09:59 +0200
Message-ID: <1443103799.1869.6.camel@sipsolutions.net>
References: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
	 <1443103227-25612-19-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Andrzej Hajda <a.hajda@samsung.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443103227-25612-19-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-09-24 at 16:00 +0200, Andrzej Hajda wrote:
> The function returns always non-negative values.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
> 
You should at least compile your patches.

johannes
