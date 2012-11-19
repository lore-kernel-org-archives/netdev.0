From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Mon, 19 Nov 2012 20:59:18 +1100
Message-ID: <1353319158.23412.88.camel@pasglop>
References: <783561822.12637564.1352139592543.JavaMail.root@vmware.com>
	 <509A06AB.2020700@redhat.com> <50A55F57.7080804@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gerd Hoffmann <kraxel@redhat.com>, Andy King <acking@vmware.com>,
	pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, David Miller <davem@davemloft.net>,
	georgezhang@vmware.com
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A55F57.7080804@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-11-15 at 15:32 -0600, Anthony Liguori wrote:
> 
> The concept was Nacked and that led to the abomination of virtio-serial.  If an 
> address family for virtualization is on the table, we should reconsider 
> AF_VMCHANNEL.
> 
> I'd be thrilled to get rid of virtio-serial...

Ack.

Ben.
