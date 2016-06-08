From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH net] Driver: Vmxnet3: segCnt can be 1 for LRO packets
Date: Tue, 7 Jun 2016 23:16:49 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1606072314540.14228@shri-linux.eng.vmware.com>
References: <1465365317-120893-1-git-send-email-skhare@vmware.com> <20160607.225910.2110750723685096426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, heoj@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160607.225910.2110750723685096426.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 7 Jun 2016, David Miller wrote:

> From: Shrikrishna Khare <skhare@vmware.com>
> Date: Tue,  7 Jun 2016 22:55:17 -0700
> 
> > The device emulation may send segCnt of 1 for LRO packets.
> > 
> > Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> > Signed-off-by: Jin Heo <heoj@vmware.com>
> 
> Please do not capitalize subsystem prefixes in your Subject line,
> and "Driver: " is so generic that it's pointless to use it as a
> part of the subsystem prefix.  Plain "vmxnet3: " is sufficient.
> 

Ok. Sent v2 of the patch with the subject line fixed.
