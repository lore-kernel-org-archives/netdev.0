From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] libertas: check for NULL before use
Date: Thu, 26 Nov 2015 13:05:38 +0000 (UTC)
Message-ID: <20151126130538.0263F14077A@smtp.codeaurora.org>
References: <1448353298-16110-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: sudip <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448353298-16110-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> If kzalloc fails it will return NULL. Lets check for NULL first before
> using the pointer.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
