From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when
 vid not used
Date: Wed, 8 Dec 2010 15:06:01 -0800
Message-ID: <20101208230601.GB8062@kroah.com>
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

It looks like I took a different, older version, I'll update it to this
one now.

thanks,

greg k-h
