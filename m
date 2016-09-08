From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v6] net: ethernet: xilinx: Enable emaclite for MIPS
Date: Thu, 8 Sep 2016 09:17:31 +0100
Message-ID: <a6cad21b-9976-6bf7-7b40-052d90a98c6a@imgtec.com>
References: <1473077274-63160-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <20160907.160733.1290853182617413775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160907.160733.1290853182617413775.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/08/2016 12:07 AM, David Miller wrote:
> From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> Date: Mon, 5 Sep 2016 13:07:54 +0100
>
>> The MIPS based xilfpga platform uses this driver.
>> Enable it for MIPS
>>
>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>>
>> ---
>> V1 -> V6 are from a series that has gotten too big.
>> So I have split this patch and am sending it separately.
>
> What tree to you expect this patch to be applied to?
>

net-next

Apologies for not mentioning.
When I sent it, I had rebased it on the top commit at the time.

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=2f5281ba2a8feaf6f0aee93356f350855bb530fc

Kind Regards,
ZubairLK
