From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: various tilegx networking fixes
Date: Wed, 18 Jul 2012 09:47:26 -0700 (PDT)
Message-ID: <20120718.094726.1297357353181354474.davem@davemloft.net>
References: <201207181640.q6IGet7P007227@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201207181640.q6IGet7P007227@lab-41.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please don't post patches like you did here.

The big problem is that you use the dates of your commit in
the email, that breaks everything.

It makes the patches appear out of order in patchwork, which make
more work for me.

Please repost these patches, and tell git-am or whatever tool you use
to not use the commit date in the outgoing emails.

THanks.
