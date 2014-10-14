From: David Miller <davem@davemloft.net>
Subject: Re: [net] genl_magic: Resolve logical-op warnings
Date: Tue, 14 Oct 2014 17:04:22 -0400 (EDT)
Message-ID: <20141014.170422.659068926985449384.davem@davemloft.net>
References: <1413293318-9070-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, linux-kernel@vger.kernel.org,
	johannes.berg@intel.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413293318-9070-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Oct 2014 06:28:38 -0700

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Resolve "logical 'and' applied to non-boolean constant" warnings"
> that appear in W=2 builds by adding !! to a bit test.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
