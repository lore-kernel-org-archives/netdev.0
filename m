From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PULL] vhost-net changes for net/3.6
Date: Sun, 22 Jul 2012 13:34:44 -0700
Message-ID: <1342989284.25472.227.camel@haakon2.linux-iscsi.org>
References: <20120721225436.GA23519@redhat.com>
	 <20120722.121942.2002727319293471163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, asias@redhat.com,
	pbonzini@redhat.com, stefanha@gmail.com,
	stefanha@linux.vnet.ibm.com, wuzhy@cn.ibm.com,
	Greg KH <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120722.121942.2002727319293471163.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi DaveM,

On Sun, 2012-07-22 at 12:19 -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 22 Jul 2012 01:54:36 +0300
> 
> > The following changes since commit 186e868786f97c8026f0a81400b451ace306b3a4:
> > 
> >   forcedeth: spin_unlock_irq in interrupt handler fix (2012-07-20 16:18:36 -0700)
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next
> > 
> > for you to fetch changes up to 163049aefdc04323a2d17ec9f2862027b43b0502:
> > 
> >   vhost: make vhost work queue visible (2012-07-22 01:22:23 +0300)
> 
> Pulled, thanks.

So target-pending/for-next-merge will need to be rebased once these bits
hit mainline for the tcm_vhost initial merge commit..

Just curious when your planning on sending out a -rc1 PULL request for
net-next..?

--nab
