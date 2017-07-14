From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: [PATCH 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Thu, 13 Jul 2017 17:36:20 -0700
Message-ID: <CAAtXAHd60PEFUpNtgy46y_pgyubSgHhJsBnmqr2qAYoE6HWVpw@mail.gmail.com>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org> <8729016553E3654398EA69218DA29EEF15BE5A6E@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "robh+dt@kernel.org" <robh+dt@kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BE5A6E@cnshjmbx02>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yuan,

On Thu, Jul 13, 2017 at 5:33 PM, YUAN Linyu
<Linyu.Yuan@alcatel-sbell.com.cn> wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Moritz Fischer
>> Sent: Friday, July 14, 2017 5:22 AM
>> To: netdev@vger.kernel.org
>> Cc: devicetree@vger.kernel.org; linux-kernel@vger.kernel.org;
>> davem@davemloft.net; mark.rutland@arm.com; robh+dt@kernel.org; Moritz
>> Fischer
>> Subject: [PATCH 1/2] dt-bindings: net: Add bindings for National Instruments
>> XGE netdev
>>
>> This adds bindings for the NI XGE 1G/10G network device.
>>
>> Signed-off-by: Moritz Fischer <mdf@kernel.org>
>> ---
>>  Documentation/devicetree/bindings/net/nixge.c | 32
>> +++++++++++++++++++++++++++
>>  1 file changed, 32 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/nixge.c
>
> It should be a text file, nixge.txt

You are absolutely right ... I need to have my head examined.
>
>>
>> diff --git a/Documentation/devicetree/bindings/net/nixge.c
>> b/Documentation/devicetree/bindings/net/nixge.c
>> new file mode 100644
>> index 0000000..9fff5a7
