From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macvtap: add ioctl to modify vnet header size
Date: Thu, 29 Apr 2010 16:40:57 +0200
Message-ID: <201004291640.57280.arnd@arndb.de>
References: <20100429135158.GA26303@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50619 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236Ab0D3UOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:14:16 -0400
In-Reply-To: <20100429135158.GA26303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 April 2010, Michael S. Tsirkin wrote:
> This adds TUNSETVNETHDRSZ/TUNGETVNETHDRSZ support
> to macvtap.

Looks good, thanks Michael!

> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>
