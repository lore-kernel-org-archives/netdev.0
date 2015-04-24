From: Hyong-Youb Kim <hkim@cspi.com>
Subject: Re: [PATCH v3] ethernet: myri10ge: use arch_phys_wc_add()
Date: Fri, 24 Apr 2015 10:57:58 +0900
Message-ID: <20150424015758.GA5300@hykim-PC>
References: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
 <20150423.142840.1391606504290988877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <mcgrof@do-not-panic.com>, <hykim@myri.com>,
	<netdev@vger.kernel.org>, <luto@amacapital.net>, <mcgrof@suse.com>,
	<sbsiddha@gmail.com>, <mingo@elte.hu>, <tglx@linutronix.de>,
	<jgross@suse.com>, <daniel.vetter@ffwll.ch>, <airlied@redhat.com>,
	<adaplas@gmail.com>, <plagnioj@jcrosoft.com>,
	<tomi.valkeinen@ti.com>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150423.142840.1391606504290988877.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 02:28:40PM -0400, David Miller wrote:
> I can't wait forever for the driver maintainers to review this, so
> I'm applying it.

FWIW, I replied to Luis's patch yesterday.  It appears on the netdev
list and patchwork.  Checked the recipient list, and it includes
netdev, but not your address.  I guess I will not make that mistake
again.

https://patchwork.ozlabs.org/patch/463481/
