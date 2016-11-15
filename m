From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] cadence: Add LSO support.
Date: Tue, 15 Nov 2016 10:15:51 -0500 (EST)
Message-ID: <20161115.101551.600646495911431463.davem@davemloft.net>
References: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
        <20161114.123038.1075174354580074536.davem@davemloft.net>
        <BN3PR07MB251641C606D02892E2196960C9BF0@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR07MB251641C606D02892E2196960C9BF0@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Tue, 15 Nov 2016 07:07:14 +0000

> Would it be good to enable UFO conditionally with some internal
> define? Ex.:

Absolutely not.
