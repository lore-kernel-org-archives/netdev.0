From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 6/10] tg3: use new TG3_FLG2_5750_PLUS flag
Date: Thu, 21 Apr 2005 17:02:12 -0700
Message-ID: <20050421170212.7245acb8.davem@davemloft.net>
References: <04132005193845.8597@laptop>
	<04132005193845.8656@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261788AbVDVANA@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193845.8656@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:45 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Replace a number of two-way if statements checking for 5750, and/or
> 5752 to reference the newly-defined TG3_FLG2_5750_PLUS flag instead.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied.
