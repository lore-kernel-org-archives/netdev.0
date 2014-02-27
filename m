From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 3/4] ath6kl: set NET_NAME_USER for P2P ifs
Date: Thu, 27 Feb 2014 17:27:21 +0200
Message-ID: <87bnxsfuee.fsf@kamboji.qca.qualcomm.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
	<1393512434-1325-4-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	<linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393512434-1325-4-git-send-email-dh.herrmann@gmail.com> (David
	Herrmann's message of "Thu, 27 Feb 2014 15:47:13 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Herrmann <dh.herrmann@gmail.com> writes:

> P2P netdevs and other devices that are created via nl80211 from user-space
> have a name provided by user-space. Therefore, set NET_NAME_USER so this
> is correctly shown in sysfs.
>
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Looks good to me.

Acked-by: Kalle Valo <kvalo@qca.qualcomm.com>

Can I take this to my ath.git tree?

-- 
Kalle Valo
