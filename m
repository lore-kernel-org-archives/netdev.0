From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/11] net: caif: convert to use DRIVER_ATTR_RO
Date: Fri, 09 Jun 2017 12:20:15 -0400 (EDT)
Message-ID: <20170609.122015.1559549095500111446.davem@davemloft.net>
References: <20170609090314.13991-1-gregkh@linuxfoundation.org>
        <20170609090314.13991-5-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dmitry.tarnyagin@lockless.no,
        netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609090314.13991-5-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri,  9 Jun 2017 11:03:08 +0200

> We are trying to get rid of DRIVER_ATTR(), and the caif driver's
> attributes can be trivially changed to use DRIVER_ATTR_RO().
> 
> Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
> Cc: <netdev@vger.kernel.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
