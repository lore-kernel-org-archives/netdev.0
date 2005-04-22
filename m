From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 10/10] tg3: add support for bcm5752 rev a1
Date: Thu, 21 Apr 2005 17:04:57 -0700
Message-ID: <20050421170457.3e49665c.davem@davemloft.net>
References: <04132005193846.8835@laptop>
	<04132005193846.8893@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193846.8893@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:46 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Replace existing ASIC_REV_5752 definition with ASIC_REV_5752_A0,
> and add definition for ASIC_REV_5752_A1. Then, add ASIC_REV_5752_A1
> to check for setting TG3_FLG2_5750_PLUS in tg3_get_invariants.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied, now off to Michael's additions :-)
