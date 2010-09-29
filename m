From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v11 12/17] Add a kconfig entry and make entry for mp
 device.
Date: Wed, 29 Sep 2010 21:39:54 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792EC64F8155@shsmsx502.ccr.corp.intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <0eed02838e581f2ef2247be8e69bc34cdecce6b2.1285385607.git.xiaohui.xin@intel.com>
 <1285595805.2263.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285595805.2263.13.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, I will move this in order next version.

Thanks
Xiaohui

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Monday, September 27, 2010 9:57 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v11 12/17] Add a kconfig entry and make entry for mp device.
>
>This patch is in the wrong position in the sequence.  It needs to be
>applied after mpassthru.c is created, not before.
>
>Ben.
>
>--
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
