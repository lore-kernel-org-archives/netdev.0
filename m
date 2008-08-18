From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 09:34:15 -0500
Message-ID: <48A98867.1010806@linux-foundation.org>
References: <48A086B6.2000901@linux-foundation.org>	 <20080811.141501.01468546.davem@davemloft.net>	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>	 <1219025114.25933.6.camel@ymzhang>	 <48A98228.9090006@linux-foundation.org> <2c0942db0808180731k7423df7ct75e3a27d404764d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	=?UTF-8?B?SWxwbyBKw6Ry?= =?UTF-8?B?dmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56866 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753363AbYHROf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 10:35:29 -0400
In-Reply-To: <2c0942db0808180731k7423df7ct75e3a27d404764d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ray Lee wrote:
> On Mon, Aug 18, 2008 at 7:07 AM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
>> Zhang, Yanmin wrote:
>>
>>> Other regressions on other machines are similar.
>> There are AIM7 regressions that are similar to tbench.
>>
>> 2.6.22  28436
>> 2.6.26  23064
> 
> Just a shot in the dark -- is this with Group Scheduling on or off?
> Off is prefered for benchmarks.

Off
