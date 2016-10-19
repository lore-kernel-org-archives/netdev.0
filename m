From: Shrikrishna Khare <skhare@shri-linux.eng.vmware.com>
Subject: Re: [PATCH net-next 5/6] net: use core MTU range checking in virt
 drivers
Date: Wed, 19 Oct 2016 15:21:35 -0700
Message-ID: <alpine.DEB.2.10.1610191520370.10567@shri-linux.eng.vmware.com>
References: <20161019023333.15760-1-jarod@redhat.com> <20161019023333.15760-6-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <virtualization@lists.linux-foundation.org>,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019023333.15760-6-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 19 Oct 2016, Jarod Wilson wrote:

> hyperv_net:
> - set min/max_mtu
> 
> virtio_net:
> - set min/max_mtu
> - remove virtnet_change_mtu
> 
> vmxnet3:
> - set min/max_mtu
> 
> CC: netdev@vger.kernel.org
> CC: virtualization@lists.linux-foundation.org
> CC: "K. Y. Srinivasan" <kys@microsoft.com>
> CC: Haiyang Zhang <haiyangz@microsoft.com>
> CC: "Michael S. Tsirkin" <mst@redhat.com>
> CC: Shrikrishna Khare <skhare@vmware.com>
> CC: "VMware, Inc." <pv-drivers@vmware.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---

The vmxnet3 part of the change looks good to me.

Thanks,
Shri
