From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: ipw2100: more cleanups
Date: Mon, 04 Jul 2005 13:49:05 +0800
Message-ID: <1120456146.27821.85.camel@debian.sh.intel.com>
References: <20050513214025.GA1863@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, netdev@oss.sgi.com, jbohac@suse.cz,
        jbenc@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050513214025.GA1863@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-13 at 23:40 +0200, Pavel Machek wrote:
> More cleanups (relative to ipw2100-1.1.0 version). Highlights include
> removing of two printk wrappers.

[snip]

> -static DEVICE_ATTR(bssinfo, S_IRUGO, show_bssinfo, NULL);

Any special reason to remove these driver sysfs entries?

Thanks,
-yi
