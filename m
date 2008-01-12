From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Sat, 12 Jan 2008 14:12:24 +0900 (JST)
Message-ID: <20080112.141224.06844600.yoshfuji@linux-ipv6.org>
References: <p73bq7smx1t.fsf@bingen.suse.de>
	<20080111.214120.129309556.yoshfuji@linux-ipv6.org>
	<20080111.174857.258424243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, vaf@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758500AbYALFMf@vger.kernel.org>
In-Reply-To: <20080111.174857.258424243.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20080111.174857.258424243.davem@davemloft.net> (at Fri, 11 Jan 2008 17:48:57 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Fri, 11 Jan 2008 21:41:20 +0900 (JST)
> 
> > There is no positive consesus on this draft
> > at the intarea meeting in Vancouver, right?
> > 
> > We cannot / should not enable that space until we have reached
> > a consensus on it.
> 
> This is so incredibly incorrect.
> 
> There is consensus on making network stacks able to use this
> address space.  And that is all that the patch does.

No, we did never make consensus on it.

> The consensus is only missing on whether to make the address
> space public or private.
> 
> This is also clearly spelled out in the draft.
> 
> It is important to get as large of a head start on this as
> possible because of how long it takes to deploy something
> like this.

Okay, though I am afraid this space will not be used widely,
we should be ready for it.

I'll make some more comments on the patch itself from
another point view.

--yoshfuji

