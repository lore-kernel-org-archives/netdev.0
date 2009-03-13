From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Sat, 14 Mar 2009 07:59:06 +0800
Message-ID: <20090313235906.GB2713@gondor.apana.org.au>
References: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com> <20090313115245.GA31949@gondor.apana.org.au> <EA929A9653AAE14F841771FB1DE5A1365F69E95C03@rrsmsx501.amr.corp.intel.com> <20090313.145448.113437230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56643 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751772AbZCMX7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:59:13 -0400
Content-Disposition: inline
In-Reply-To: <20090313.145448.113437230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 02:54:48PM -0700, David Miller wrote:
> 
> Herbert, want me to toss this into net-2.6 now?

No, the bug only exists in net-next-2.6 :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
