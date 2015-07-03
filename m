From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: remove duplicated function definition
Date: Fri, 03 Jul 2015 09:54:56 -0700 (PDT)
Message-ID: <20150703.095456.896840617547142096.davem@davemloft.net>
References: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: liang.z.li@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liang Li <liang.z.li@intel.com>
Date: Sat,  4 Jul 2015 03:33:00 +0800

> There are two duplicated xenvif_zerocopy_callback() definitions.
> Remove one of them.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>

You really need to fix the date on your computer.

If your date is in the future, as your's is, then your patch appears
out-of-order in the patchwork patch queue since it is ordered by the
Date: field in the email.
