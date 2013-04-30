From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: use random MAC address if no valid one supplied
Date: Wed, 01 May 2013 00:18:43 +0400
Message-ID: <51802723.9020105@cogentembedded.com>
References: <201304292349.43251.sergei.shtylyov@cogentembedded.com> <20130430.153729.859998606300915403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20130430.153729.859998606300915403.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/30/2013 11:37 PM, David Miller wrote:

>
>> On Renesas R-Car based development boards, although a MAC address is printed on
>> all the Ethernet port labels, U-Boot  doesn't write a valid MAC address  to the
>> Ether MAHR/MALR registers (there's no storage provided for the Ether MAC address
>> either), so we have to resort to using a random MAC address...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Applied, thanks.

     Thanks to you. I thought I'll have to wait after merge window 
closes now... :-)

WBR, Sergei

