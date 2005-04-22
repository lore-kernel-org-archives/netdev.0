From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 4/10] tg3: use TG3_FLG2_5705_PLUS instead of
 multi-way if's
Date: Thu, 21 Apr 2005 17:00:43 -0700
Message-ID: <20050421170043.6845519a.davem@davemloft.net>
References: <04132005193844.8474@laptop>
	<04132005193844.8539@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261774AbVDVAKp@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193844.8539@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:44 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Replace a number of three-way if statements checking for 5705, 5750,
> and 5752 to reference the equivalent TG3_FLG2_5705_PLUS flag instead.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied.
