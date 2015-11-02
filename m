From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 0/2] sh_eth: fix bugs in sh_eth_ring_init()
Date: Tue, 3 Nov 2015 01:31:41 +0300
Message-ID: <5637E44D.1070006@cogentembedded.com>
References: <3291270.dPgp9opalf@wasted.cogentembedded.com>
 <20151102.155639.1614788692883883662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20151102.155639.1614788692883883662.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2015 11:56 PM, David Miller wrote:

>>     Here's a set of 2 patches against DaveM's 'net.git' repo which fix couple of
>> bugs in the sh_eth_ring_init() function.
>
> Series applied.

    As these fixed the error path, I don't expect you to push them to -stable, 
but your call.

MBR, Sergei

