From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ethernet: myri10ge: use arch_phys_wc_add()
Date: Thu, 23 Apr 2015 22:35:06 -0400 (EDT)
Message-ID: <20150423.223506.1929957496445086975.davem@davemloft.net>
References: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
	<20150423.142840.1391606504290988877.davem@davemloft.net>
	<20150424015758.GA5300@hykim-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcgrof@do-not-panic.com, hykim@myri.com, netdev@vger.kernel.org,
	luto@amacapital.net, mcgrof@suse.com, sbsiddha@gmail.com,
	mingo@elte.hu, tglx@linutronix.de, jgross@suse.com,
	daniel.vetter@ffwll.ch, airlied@redhat.com, adaplas@gmail.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	linux-kernel@vger.kernel.org
To: hkim@cspi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150424015758.GA5300@hykim-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hyong-Youb Kim <hkim@cspi.com>
Date: Fri, 24 Apr 2015 10:57:58 +0900

> X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Apr 2015 01:58:46.2847 (UTC)
> X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
> X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB5PR05MB1302
> X-Greylist: Default is to whitelist mail, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 23 Apr 2015 18:58:55 -0700 (PDT)
> Content-Type: text/plain; charset="us-ascii"
> Content-Disposition: inline
> Subject: Re: [PATCH v3] ethernet: myri10ge: use arch_phys_wc_add()
> From: Hyong-Youb Kim <hkim@cspi.com>
> To: David Miller <davem@davemloft.net>
> CC: <mcgrof@do-not-panic.com>, <hykim@myri.com>, <netdev@vger.kernel.org>,
> 	<luto@amacapital.net>, <mcgrof@suse.com>, <sbsiddha@gmail.com>,
> 	<mingo@elte.hu>, <tglx@linutronix.de>, <jgross@suse.com>,
> 	<daniel.vetter@ffwll.ch>, <airlied@redhat.com>, <adaplas@gmail.com>,
> 	<plagnioj@jcrosoft.com>, <tomi.valkeinen@ti.com>,
> 	<linux-kernel@vger.kernel.org>
> Date: Fri, 24 Apr 2015 10:57:58 +0900
> User-Agent: Mutt/1.5.23 (2014-03-12)
> 
> On Thu, Apr 23, 2015 at 02:28:40PM -0400, David Miller wrote:
>> I can't wait forever for the driver maintainers to review this, so
>> I'm applying it.
> 
> FWIW, I replied to Luis's patch yesterday.  It appears on the netdev
> list and patchwork.  Checked the recipient list, and it includes
> netdev, but not your address.  I guess I will not make that mistake
> again.

I saw it.

You did not supply an Acked-by: or Tested-by: tag in that response.

Also, if you are not going to use the email address listed in the
MAINTAINERS entry for this driver, you should update it so I know
what email addresses to look for to know if someone is responsible
for that driver or not.

Thanks.
