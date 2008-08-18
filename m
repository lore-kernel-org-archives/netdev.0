From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 07:31:05 -0700
Message-ID: <2c0942db0808180731k7423df7ct75e3a27d404764d0@mail.gmail.com>
References: <48A086B6.2000901@linux-foundation.org>
	 <20080811.141501.01468546.davem@davemloft.net>
	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
	 <1219025114.25933.6.camel@ymzhang>
	 <48A98228.9090006@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	"=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"David Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Christoph Lameter" <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:3324 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbYHRObG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 10:31:06 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2008037rvb.1
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 07:31:05 -0700 (PDT)
In-Reply-To: <48A98228.9090006@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 7:07 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Zhang, Yanmin wrote:
>
>> Other regressions on other machines are similar.
>
> There are AIM7 regressions that are similar to tbench.
>
> 2.6.22  28436
> 2.6.26  23064

Just a shot in the dark -- is this with Group Scheduling on or off?
Off is prefered for benchmarks.
