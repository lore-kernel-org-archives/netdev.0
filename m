From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] dt-bindings: net: renesas-ravb: Add support for R8A77995
 RAVB
Date: Wed, 13 Sep 2017 19:08:53 +0300
Message-ID: <1e2957a8-b2e8-a5a5-fed9-dd9d249b03eb@cogentembedded.com>
References: <1505305060-4192-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
 <1f4763ea-9f8a-03a6-1215-69b96c404590@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        devicetree@vger.kernel.org
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
        davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1f4763ea-9f8a-03a6-1215-69b96c404590@cogentembedded.com>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/13/2017 07:02 PM, Sergei Shtylyov wrote:

>> Add a new compatible string for the R8A77995 (R-Car D3) RAVB.
>>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>> ---
>>   Documentation/devicetree/bindings/net/renesas,ravb.txt | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt 
>> b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> index 1672353..ae2213f 100644
>> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> @@ -17,6 +17,7 @@ Required properties:
>>         - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
>>         - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
>> +      - "renesas,etheravb-r8a77995" for the R8A77995 SoC.
> 
>     That would conflict with the R8A77970 bindings patch posted by me 
> yesterday. Please respin atop of it.

    Here's the link for your convenience:

https://marc.info/?l=linux-renesas-soc&m=150524655515476

[...]

MBR, Sergei
