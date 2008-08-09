From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 11:20:56 +0800
Message-ID: <20080809032055.GA27212@gondor.apana.org.au>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808090354.03568.wolfgang.walter@stwm.de> <20080809021649.GA26784@gondor.apana.org.au> <200808090509.53679.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33880 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752894AbYHIDVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 23:21:07 -0400
Content-Disposition: inline
In-Reply-To: <200808090509.53679.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 05:09:53AM +0200, Wolfgang Walter wrote:
> 
> I'll run that test on a unpatched 2.6.25 instead a unpatched 2.6.26 as latter 
> will crash. If you want I can use my 2.6.26 where I reverted the FPU state 
> changes (see one of my earlier mails for the patch), of course.

2.6.25 should be fine as not much has changed in the padlock.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
