From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: simplify conditional
Date: Sat, 09 Oct 2010 09:21:03 -0700 (PDT)
Message-ID: <20101009.092103.91350825.davem@davemloft.net>
References: <20101008011450.0126ffc0@absol.kitzblitz>
	<4CAE5C71.50304@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikai@nikai.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CAE5C71.50304@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Thu, 07 Oct 2010 20:49:05 -0300

> On 10/07/2010 08:14 PM, Nicolas Kaiser wrote:
>> Simplify: ((a&&  b) || (!a&&  !b)) =>  (a == b)
>>
>> Signed-off-by: Nicolas Kaiser<nikai@nikai.net>
> Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
