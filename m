From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/8] Multiqueue API for macvtap
Date: Fri, 07 Jun 2013 23:49:50 -0700 (PDT)
Message-ID: <20130607.234950.32504786500736858.davem@davemloft.net>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu,  6 Jun 2013 17:54:32 +0800

> This series implements a fully tuntap compatiable API which could be used
> by userspace to manage multiple macvtap queues. The main parts is to add
> TUNSETQUEUE ioctl support for macvtap.

Series applied, thanks everyone.
