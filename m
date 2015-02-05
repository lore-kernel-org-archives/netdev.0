From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARCNET: Add missing error check for devm_kzalloc
Date: Thu, 05 Feb 2015 15:53:46 -0800 (PST)
Message-ID: <20150205.155346.325835289815021228.davem@davemloft.net>
References: <1423135897-20448-1-git-send-email-kiran.padwal@smartplayin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.grzeschik@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kiran.padwal21@gmail.com
To: kiran.padwal@smartplayin.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423135897-20448-1-git-send-email-kiran.padwal@smartplayin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kiran Padwal <kiran.padwal@smartplayin.com>
Date: Thu,  5 Feb 2015 17:01:37 +0530

> This patch add a missing check on the return value of devm_kzalloc,
> which would cause a NULL pointer dereference in a OOM situation.
> 
> Signed-off-by: Kiran Padwal <kiran.padwal@smartplayin.com>

Applied, thanks.
