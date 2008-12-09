From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCIe ASPM causes machine (HP Compaq 6735s) to sometimes freeze hard at boot at PCI initialization time
Date: Tue, 9 Dec 2008 15:05:10 -0800
Message-ID: <200812091505.11313.jbarnes@virtuousgeek.org>
References: <200811281328.55259.trenn@suse.de> <1228785579.9482.2.camel@sli10-desk.sh.intel.com> <200812091305.10824.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Shaohua Li <shaohua.li@intel.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Rafael Wysocki <rwysocki@suse.de>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Stable@kernel.org" <Stable@kernel.org>
To: Thomas Renninger <trenn@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756146AbYLIXFv@vger.kernel.org>
In-Reply-To: <200812091305.10824.trenn@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, December 09, 2008 4:05 am Thomas Renninger wrote:
> Hi Jesse,
>
> can you add this one, please.
> I adjusted the patch to suggestions from Matthew and Shaohua, thus
> added their Signed-offs.
>
> This should still go into .28 as it makes machines boot which
> now freeze since the ASPM patch was introduced.

Ok, just pushed it.  Thanks.

Jesse
