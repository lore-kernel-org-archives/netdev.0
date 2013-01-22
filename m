From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 12/20] drivers/net/wireless/ath/ath6kl: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 20:36:48 +0200
Message-ID: <87r4ldcben.fsf@kamboji.qca.qualcomm.com>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
	<1358879444-25834-13-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-13-git-send-email-keescook@chromium.org> (Kees
	Cook's message of "Tue, 22 Jan 2013 10:30:36 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> writes:

> The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
> while now and is almost always enabled by default. As agreed during the
> Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

Do you want me to apply this to ath6kl.git (the normal route for ath6kl
patches) or what's the plan?

-- 
Kalle Valo
