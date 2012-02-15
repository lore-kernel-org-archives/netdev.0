From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] renesas/sh_eth.c: fix linux/interrupt.h included twice
Date: Wed, 15 Feb 2012 15:35:03 -0500 (EST)
Message-ID: <20120215.153503.788456242769079702.davem@davemloft.net>
References: <1329328483-4682-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, yoshihiro.shimoda.uh@renesas.com,
	nobuhiro.iwamatsu.yj@renesas.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329328483-4682-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Wed, 15 Feb 2012 18:54:43 +0100

> Remove double include of linux/interrupt.h.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
