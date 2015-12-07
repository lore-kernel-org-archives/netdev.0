From: Kalle Valo <kvalo@codeaurora.org>
Subject: Fixing full name in patchwork
Date: Mon, 07 Dec 2015 20:03:54 +0200
Message-ID: <87zixmb0fp.fsf@kamboji.qca.qualcomm.com>
References: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
	(Sudip Mukherjee's message of "Mon, 23 Nov 2015 18:02:02 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sudip,

Sudip Mukherjee <sudipm.mukherjee@gmail.com> writes:

> We were dereferencing cmd first and checking for NULL later. Lets first
> check for NULL.
>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

I noticed that your name in git log is not your full name:

commit 0a38c8e1b592c16d959da456f425053e323a5153
Author: sudip <sudipm.mukherjee@gmail.com>
Date:   Tue Nov 24 13:51:38 2015 +0530

This is because for some reason in patchwork your fullname is just
"sudip":

https://patchwork.kernel.org/patch/7688171/

Could you please fix your name in patchwork so that in the future we can
use your correct full name? The problem is that I don't know exactly how
to do this but it should be possible because I remember someone else
having a similar problem and he was able to fix it.

-- 
Kalle Valo
