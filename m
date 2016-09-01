From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v3 07/11] MIPS: Xilfpga: Add DT node for AXI I2C
Date: Thu, 1 Sep 2016 16:22:24 +0100
Message-ID: <6257058c-ae15-ff06-1f01-6e89dc23f2fd@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-8-git-send-email-Zubair.Kakakhel@imgtec.com>
 <74279d97-beeb-e754-40ad-3bfc8eeba66d@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Lars-Peter Clausen <lars@metafoo.de>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:39936 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752955AbcIAPWh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:22:37 -0400
In-Reply-To: <74279d97-beeb-e754-40ad-3bfc8eeba66d@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/01/2016 11:57 AM, Lars-Peter Clausen wrote:
> On 08/31/2016 06:35 PM, Zubair Lutfullah Kakakhel wrote:
> [..]
>> +	    ad7420@4B {
>> +		compatible = "adt7420";
>
> "adi,adt7420"

danke schoen

:)
ZubairLK

>
>> +		reg = <0x4B>;
>> +	    };
>> +	} ;
>>  };
