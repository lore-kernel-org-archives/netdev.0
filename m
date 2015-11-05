From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 5 Nov 2015 17:41:10 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFAF10E@fmsmsx115.amr.corp.intel.com>
References: <20151105.103126.148818796422971143.davem@davemloft.net>
	<20151105.110506.1901401372160830603.davem@davemloft.net>
	<20151105162831.GA5642@oracle.com>
 <20151105.112920.2123583342530330617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: David Miller <davem@davemloft.net>,
	"sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105.112920.2123583342530330617.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, November 05, 2015 8:29 AM
> 
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Thu, 5 Nov 2015 11:28:31 -0500
> 
> > On (11/05/15 11:05), David Miller wrote:
> >> From: David Miller <davem@davemloft.net>
> >> Date: Thu, 05 Nov 2015 10:31:26 -0500 (EST)
> >>
> >> > I'll see if I can cook something up.
> >>
> >> How does this look?
> >
> > Looks good to me,
> >
> > Do you want me to respin patch v7 with this? Or update ixgbe/i40e to
> use
> > this later, after this goes in?
> 
> The intention is to let your patch go in as-is, then try and update
> ixgbe/i40e later in net-next or similar.

That works for us as well - thanks!
sln
