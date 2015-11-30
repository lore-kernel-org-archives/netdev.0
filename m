From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH v3] ath6kl: Use vmalloc for loading firmware using api1 method and use kvfree
Date: Mon, 30 Nov 2015 10:48:57 +0200
Message-ID: <87vb8jlvnq.fsf@kamboji.qca.qualcomm.com>
References: <1448774038-26984-1-git-send-email-motobud@gmail.com>
	<1448776283-28383-1-git-send-email-motobud@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <ath6kl@lists.infradead.org>,
	<linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Brent Taylor <motobud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448776283-28383-1-git-send-email-motobud@gmail.com> (Brent
	Taylor's message of "Sat, 28 Nov 2015 23:51:23 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brent Taylor <motobud@gmail.com> writes:

> Signed-off-by: Brent Taylor <motobud@gmail.com>
>
> ath6kl: Use vmalloc for loading firmware using api1 method and free using kvfree
>
> ath6kl: fix kmalloc build error
> ---
> Changes v2 -> v3:
>    - fix kmalloc build error
>
> Changes v1 -> v2:
>    - simplify memory allocation
>    - use kvfree

The commit log in v3 is even worse.

-- 
Kalle Valo
