From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v13 10/16] Add a hook to intercept external buffers from
 NIC driver.
Date: Mon, 8 Nov 2010 15:43:11 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79338D121BB7@shsmsx502.ccr.corp.intel.com>
References: <33f51c5eddec843260451eccbfa3c5fdea13b479.1287132437.git.xiaohui.xin@intel.com>
	<20101019.082401.28817543.davem@davemloft.net>
	<F2E9EB7348B8264F86B6AB8151CE2D7931E3CB834A@shsmsx502.ccr.corp.intel.com>
 <20101029.132836.115944599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35938 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab0KHHnr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 02:43:47 -0500
In-Reply-To: <20101029.132836.115944599.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have addressed this issue in v14 patch set.

Thanks
Xiaohui

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Saturday, October 30, 2010 4:29 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: Re: [PATCH v13 10/16] Add a hook to intercept external buffers from NIC driver.
>
>From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
>Date: Wed, 27 Oct 2010 09:33:12 +0800
>
>> Somehow, it seems not a trivial work to support it now. Can we support it
>> later and as a todo with our current work?
>
>I would prefer the feature work properly, rather than only in specific
>cases, before being integated.
