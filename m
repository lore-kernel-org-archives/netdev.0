From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Sat, 09 Aug 2008 22:41:48 -0700
Message-ID: <489E7F9C.9000708@zytor.com>
References: <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809003829.GA25926@gondor.apana.org.au> <20080809142918.GA30387@gondor.apana.org.au> <20080809143259.GA30451@gondor.apana.org.au> <20080809175247.GD13158@linux-os.sc.intel.com> <20080810053048.GA3171@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	austin zhang <austin_zhang@linux.intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:32828 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbYHJFsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 01:48:33 -0400
In-Reply-To: <20080810053048.GA3171@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Aug 09, 2008 at 10:52:48AM -0700, Suresh Siddha wrote:
>>> Actually I was mistaken, Intel has done the right thing by not
>>> generating a fault on crc32c with TS set.
>> Yes, the documentation seems to says so. But I am double checking
>> with experts inside, to make sure we got the SDM right.
> 
> Thanks for checking this!

Indeed :)

	-hpa
