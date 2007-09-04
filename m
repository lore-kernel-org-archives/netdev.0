From: Zach Carter <linux@zachcarter.com>
Subject: Re: 2.6.23-rc4-mm1
Date: Tue, 4 Sep 2007 10:54:32 -0700
Message-ID: <200709041054.32859.linux@zachcarter.com>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755890AbXIDRyo@vger.kernel.org>
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +ioc3-program-uart-predividers.patch
> +sky2-fe-chip-support.patch
> +sky2-use-debugfs-rename.patch
> +sky2-document-gphy_ctrl-bits.patch
> +sky2-dont-restrict-config-space-access.patch
> +sky2-advanced-error-reporting.patch
> +sky2-use-pci_config-access-functions.patch
> +sky2-use-net_device-internal-stats.patch
> +ktime_sub_ns-analog-of-ktime_add_ns.patch
> +export-reciprocal_value-for-modules.patch
> +sky2-hardware-receive-timestamp-counter.patch
> +sky2-avoid-divide-in-receive-path.patch
> +sky2-118.patch

Folks,

I've got these messages since installing 2.6.23-rc4-mm1:

sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 5 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 5 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000
printk: 4 messages suppressed.
sky2 0000:07:00.0: error interrupt status=0x80000000

The laptop is a Sony VAIO SZ430N/B

Despite the errors, the interface appears to be working well enough.

I'd be happy to supply additional information, try out patches, or 
submit a bugzilla if needed.

thanks!

-Zach
