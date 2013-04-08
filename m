From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211_hwsim: Register and bind to driver
Date: Mon, 08 Apr 2013 16:32:49 +0200
Message-ID: <1365431569.25475.16.camel@jlt4.sipsolutions.net>
References: <20130408093001.GE2818@piware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>
To: Martin Pitt <martin.pitt@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:53052 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936284Ab3DHOc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 10:32:56 -0400
In-Reply-To: <20130408093001.GE2818@piware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 11:30 +0200, Martin Pitt wrote:
> Properly register our mac80211_hwsim_driver, attach it to the platform bus.
> Bind newly created hwsim devices to that driver, so that our wlan devices get
> a proper "driver" sysfs attribute.
> 
> This makes mac80211_hwsim interfaces work with NetworkManager.

Applied.

johannes
