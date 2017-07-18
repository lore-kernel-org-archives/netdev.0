From: Arun Parameswaran <arun.parameswaran@broadcom.com>
Subject: Re: [PATCH v1 1/1] dt-binding: ptp: Add SoC compatibility strings for
 dte ptp clock
Date: Tue, 18 Jul 2017 10:14:16 -0700
Message-ID: <30d0208e-aa15-63bd-c781-8846054f0dfe@broadcom.com>
References: <1499362677-28579-1-git-send-email-arun.parameswaran@broadcom.com>
 <20170710134437.ribkgkpwf2hlvelv@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710134437.ribkgkpwf2hlvelv@rob-hp-laptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 17-07-10 06:44 AM, Rob Herring wrote:
> On Thu, Jul 06, 2017 at 10:37:57AM -0700, Arun Parameswaran wrote:
>> Add SoC specific compatibility strings to the Broadcom DTE
>> based PTP clock binding document.
>>
>> Fixed the document heading and node name.
>>
>> Fixes: 80d6076140b2 ("dt-binding: ptp: add bindings document for dte based ptp clock")
>> Signed-off-by: Arun Parameswaran <arun.parameswaran@broadcom.com>
>> ---
>>  Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 15 +++++++++++----
>>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> Acked-by: Rob Herring <robh@kernel.org>
>
Will you be picking up this change ?

Thanks
Arun
