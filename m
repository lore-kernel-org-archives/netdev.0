From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: [PATCH] ath9k_htc: Fix skb leaks
Date: Wed, 9 Jan 2013 13:49:47 +0530
Message-ID: <20717.10275.994429.552141@gargle.gargle.HOWL>
References: <1357098567-8558-1-git-send-email-Larry.Finger@lwfinger.net>
	<20707.47067.474241.813195@gargle.gargle.HOWL>
	<50E3BE23.3010102@lwfinger.net>
	<20707.50445.510814.481023@gargle.gargle.HOWL>
	<50EC44B5.6020605@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	ath9k-devel@lists.ath9k.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2plout10-02.prod.sin2.secureserver.net ([182.50.145.5]:55601
	"EHLO sg2plout10-02.prod.sin2.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757020Ab3AIIUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 03:20:47 -0500
In-Reply-To: <50EC44B5.6020605@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger wrote:
> > I'll come up with a patch and see if kmemleak still complains.
> 
> Did I miss your posting on this issue?

Nope, I haven't got to this yet, sorry. I'll try to send a patch by today.

Sujith
