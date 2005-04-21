From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 1/10] tg3: add basic bcm5752 support
Date: Thu, 21 Apr 2005 16:57:29 -0700
Message-ID: <20050421165729.27c0b6ad.davem@davemloft.net>
References: <04132005193843.8300@laptop>
	<04132005193843.8351@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261732AbVDVAEh@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193843.8351@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:43 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Track-down all references to ASIC_REV_5750 and mirror them with
> references to the newly defined ASIC_REV_5752.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

You don't actually add the ASIC_REV_5752 definition to tg3.h,
but I took care of that for you when checking this patch in.

Applied, thanks.
