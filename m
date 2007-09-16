From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] jumbo all-NICs ethtool count cleanup
Date: Sun, 16 Sep 2007 08:27:22 +0200
Message-ID: <20070916062722.GA5498@uranus.ravnborg.org>
References: <20070916061015.GA11373@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:36121 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbXIPGZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 02:25:58 -0400
Content-Disposition: inline
In-Reply-To: <20070916061015.GA11373@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff.

You wrote:
> The hooks ->self_test_count() and ->get_stats_count() are now unused
> in the main tree.

So I'm suprised to see more lines added than deleted:
>  35 files changed, 346 insertions(+), 246 deletions(-)

Puzzled - may need a bit more coffee (morning here)..

	Sam
