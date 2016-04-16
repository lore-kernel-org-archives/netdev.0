From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: WARNING: CPU: 1 PID: 2485 at
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c:1752
 iwl_trans_pcie_grab_nic_access+0x110/0x120 [iwlwifi]
Date: Sat, 16 Apr 2016 17:43:48 +0200
Message-ID: <20160416154348.GA2069@cz.tnic>
References: <20160415020710.GA2700@cz.tnic>
 <1460693762.2648.5.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxwifi <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Dreyfuss, Haim" <haim.dreyfuss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Coelho, Luciano" <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1460693762.2648.5.camel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 04:16:02AM +0000, Grumbach, Emmanuel wrote:
> [1] https://git.kernel.org/cgit/linux/kernel/git/iwlwifi/backport-iwlwi
> fi.git/

It is very strange to pull from this repo, git fetch is doing something
for a while now without any forward progress.

In any case, 4.5 is bad too, testing 4.4 now. I'm travelling currently
so the whole bisection deal will take a whole but I'll get to it
eventually.

Thanks for taking a look.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply. Srsly.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
