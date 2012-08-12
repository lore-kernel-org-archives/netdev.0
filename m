From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Fix compiler warnings
Date: Sun, 12 Aug 2012 13:42:25 -0700 (PDT)
Message-ID: <20120812.134225.1778015851322929441.davem@davemloft.net>
References: <1344741035-1493-1-git-send-email-joren.vanonder@gmail.com>
	<50273628.50503@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joren.vanonder@gmail.com, eilong@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yuvalmin@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50273628.50503@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 12 Aug 2012 07:50:48 +0300

>> Fix the following compiler warnings:
>> 
>>  - drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2908:3: warning: comparison
>>    of distinct pointer types lacks a cast [enabled by default]
>>  - drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:1709:7: warning: comparison
>>    of distinct pointer types lacks a cast [enabled by default]
>> 
>> Signed-off-by: Joren Van Onder <joren.vanonder@gmail.com>
> Thanks Joren.
> Acked-By: Yuval Mintz <yuvalmin@broadcom.com>

Applied.
