From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Thu, 07 Jun 2012 14:43:58 -0700 (PDT)
Message-ID: <20120607.144358.1732928576389957779.davem@davemloft.net>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
	<4FD11F49.5060805@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rkagan@parallels.com, stable@vger.kernel.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	dnelson@redhat.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, tarbal@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FD11F49.5060805@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <tarbal@gmail.com>
Date: Thu, 07 Jun 2012 14:38:17 -0700

> Thanks! I have applied the patch to my queue

Why?

My impression is that this is a patch already in the tree, and it's
being submitted for -stable but such minor performance hacks are
absolutely not appropriate for -stable submission.
