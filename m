From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH -next 13/26] ath: Use dma_zalloc_coherent
Date: Mon, 16 Jun 2014 12:24:46 +0300
Message-ID: <87fvj52om9.fsf@kamboji.qca.qualcomm.com>
References: <cover.1402863904.git.joe@perches.com>
	<55b103a2ec78c0031b348e103603bf9a0d9cac3b.1402863905.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	<ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <wcn36xx@lists.infradead.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55b103a2ec78c0031b348e103603bf9a0d9cac3b.1402863905.git.joe@perches.com>
	(Joe Perches's message of "Sun, 15 Jun 2014 13:37:42 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> Use the zeroing function instead of dma_alloc_coherent & memset(,0,)
>
> Signed-off-by: Joe Perches <joe@perches.com>

For ath10k:

Acked-by: Kalle Valo <kvalo@qca.qualcomm.com>

-- 
Kalle Valo
