From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Fix use of mfTableLen for big
 endian architectures
Date: Mon, 16 Nov 2015 13:20:50 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1511161318430.16991@shri-linux.eng.vmware.com>
References: <1447458130-31985-1-git-send-email-skhare@vmware.com> <20151116.150634.1258914853943067233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, uebayasi@gmail.com, bhavesh@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.150634.1258914853943067233.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 16 Nov 2015, David Miller wrote:

> From: Shrikrishna Khare <skhare@vmware.com>
> Date: Fri, 13 Nov 2015 15:42:10 -0800
> 
> > Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> > Reported-by: Masao Uebayashi <uebayasi@gmail.com>
> > Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> 
> You guys really have to stop targetting simple, straightforward,
> bug fixes at net-next.  That is not appropriate.
> 
> Bug fixes should target 'net'.

Thanks for applying this patch to net.

Will send similar patches to net in future.

Thanks,
Shri 
