From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when
 vid not used
Date: Wed, 8 Dec 2010 15:16:24 -0800
Message-ID: <20101208231624.GA8992@kroah.com>
References: <1291108809.2904.3.camel@edumazet-laptop>
 <20101201111716.424fb771@xenia.leun.net>
 <1291200914.2856.546.camel@edumazet-laptop>
 <20101208.084731.189716071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, lkml20101129@newton.leun.net,
	netdev@vger.kernel.org, jesse@nicira.com,
	linux-kernel@vger.kernel.org, greearb@candelatech.com,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101208.084731.189716071.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2010 at 08:47:31AM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 01 Dec 2010 11:55:14 +0100
> 
> 
> Greg/-stable, please integrate this patch from Eric into 2.6.36 if you
> haven't already done so.

I've updated the version in the .36-stable queue with this one, thanks.

greg k-h
