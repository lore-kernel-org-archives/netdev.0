From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: Re: [PATCH] xen-netback: remove duplicated function
	definition
Date: Sat, 4 Jul 2015 15:43:47 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E55D931@shsmsx102.ccr.corp.intel.com>
References: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
	<20150703.095456.896840617547142096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20150703.095456.896840617547142096.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

> Cc: linux-kernel@vger.kernel.org; ian.campbell@citrix.com;
> wei.liu2@citrix.com; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] xen-netback: remove duplicated function definition
> 
> From: Liang Li <liang.z.li@intel.com>
> Date: Sat,  4 Jul 2015 03:33:00 +0800
> 
> > There are two duplicated xenvif_zerocopy_callback() definitions.
> > Remove one of them.
> >
> > Signed-off-by: Liang Li <liang.z.li@intel.com>
> 
> You really need to fix the date on your computer.
> 
> If your date is in the future, as your's is, then your patch appears out-of-
> order in the patchwork patch queue since it is ordered by the
> Date: field in the email.

OK. Thanks for your reminding.
