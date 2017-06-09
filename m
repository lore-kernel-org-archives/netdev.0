From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] net: ehea: convert to use DRIVER_ATTR_RO
Date: Fri, 09 Jun 2017 12:20:04 -0400 (EDT)
Message-ID: <20170609.122004.1871611888304969719.davem@davemloft.net>
References: <20170609090314.13991-1-gregkh@linuxfoundation.org>
        <20170609090314.13991-6-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dougmill@linux.vnet.ibm.com,
        netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609090314.13991-6-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri,  9 Jun 2017 11:03:09 +0200

> We are trying to get rid of DRIVER_ATTR(), and the ehea driver's
> attribute can be trivially changed to use DRIVER_ATTR_RO().
> 
> Cc: Douglas Miller <dougmill@linux.vnet.ibm.com>
> Cc: <netdev@vger.kernel.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
