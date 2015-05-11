From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [net-next PATCH v3 1/4] devicetree: Add compatible string for
 Zynq Ultrascale+ MPSoC
Date: Mon, 11 May 2015 13:59:31 +0530
Message-ID: <CAFcVECLzyzOfkip-w95kA4M-pVrZvCa+-JRSBe==ppLo+tWfDQ@mail.gmail.com>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
	<55505D3E.2050303@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Harini Katakam <harini.katakam@xilinx.com>, davem@davemloft.net,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55505D3E.2050303@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 11, 2015 at 1:11 PM, Nicolas Ferre <nicolas.ferre@atmel.com=
> wrote:
> Le 06/05/2015 18:57, Harini Katakam a =C3=A9crit :
>> Add "cdns,zynqmp-gem" to be used for Zynq Ultrascale+ MPSoC.
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
>
> I know it's too late, but for the record:
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks!

Regards,
Harini

>
> Thanks for having re-spinned this series Harini.
>
> Bye,
>
>
>> ---
>>
>> v3:
>> No changes
>>
>> v2:
>> Updated SoC name
>>
>> ---
>>  Documentation/devicetree/bindings/net/macb.txt |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Docume=
ntation/devicetree/bindings/net/macb.txt
>> index ba19d67..8ec5fdf 100644
>> --- a/Documentation/devicetree/bindings/net/macb.txt
>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> @@ -9,6 +9,7 @@ Required properties:
>>    the Cadence GEM, or the generic form: "cdns,gem".
>>    Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama=
5d3 SoCs.
>>    Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama=
5d4 SoCs.
>> +  Use "cdns,zynqmp-gem" for Zynq Ultrascale+ MPSoC.
>>  - reg: Address and length of the register set for the device
>>  - interrupts: Should contain macb interrupt
>>  - phy-mode: See ethernet.txt file in the same directory.
>>
>
>
> --
> Nicolas Ferre
