From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Fix delay argument of schedule_delayed_work
Date: Thu, 16 Apr 2009 02:43:47 -0700 (PDT)
Message-ID: <20090416.024347.22681928.davem@davemloft.net>
References: <1239811551-6101-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcin.slusarz@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754750AbZDPJoR@vger.kernel.org>
In-Reply-To: <1239811551-6101-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu, 16 Apr 2009 01:05:51 +0900

> The commit a390d1f3 ("phylib: convert state_queue work to
> delayed_work") missed converting 'expires' value to 'delay' value.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied, thank you very much.
