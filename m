From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Sun, 12 May 2013 00:31:34 +0400
Message-ID: <518EAAA6.2030301@cogentembedded.com>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de> <1368173847-5661-18-git-send-email-wsa@the-dreams.de> <518CD501.1040909@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518CD501.1040909@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/10/2013 03:07 PM, Sergei Shtylyov wrote:

>
>> devm_ioremap_resource does sanity checks on the given resource. No 
>> need to
>> duplicate this in the driver.
>
>> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

     I was too fast, I'm now withdawing my ACK.

> WBR, Sergei
>

WBR, Sergei
