From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 9/10] tg3: check TG3_FLG2_5750_PLUS flag to
 set TG3_FLG2_5705_PLUS flag
Date: Thu, 21 Apr 2005 17:04:00 -0700
Message-ID: <20050421170400.6a6fd892.davem@davemloft.net>
References: <04132005193845.8775@laptop>
	<04132005193846.8835@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193846.8835@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:46 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Use check of TG3_FLG2_5750_PLUS in tg3_get_invariants to set
> TG3_FLG2_5705_PLUS flag.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied.
