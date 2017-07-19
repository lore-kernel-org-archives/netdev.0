From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] dt-binding: ptp: Add SoC compatibility strings
 for dte ptp clock
Date: Wed, 19 Jul 2017 16:26:44 -0700 (PDT)
Message-ID: <20170719.162644.1667083105877113459.davem@davemloft.net>
References: <1499362677-28579-1-git-send-email-arun.parameswaran@broadcom.com>
        <20170710134437.ribkgkpwf2hlvelv@rob-hp-laptop>
        <30d0208e-aa15-63bd-c781-8846054f0dfe@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh@kernel.org, richardcochran@gmail.com, mark.rutland@arm.com,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: arun.parameswaran@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30d0208e-aa15-63bd-c781-8846054f0dfe@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arun Parameswaran <arun.parameswaran@broadcom.com>
Date: Tue, 18 Jul 2017 10:14:16 -0700

> Hi David,
> 
> On 17-07-10 06:44 AM, Rob Herring wrote:
>> On Thu, Jul 06, 2017 at 10:37:57AM -0700, Arun Parameswaran wrote:
>>> Add SoC specific compatibility strings to the Broadcom DTE
>>> based PTP clock binding document.
>>>
>>> Fixed the document heading and node name.
>>>
>>> Fixes: 80d6076140b2 ("dt-binding: ptp: add bindings document for dte based ptp clock")
>>> Signed-off-by: Arun Parameswaran <arun.parameswaran@broadcom.com>
>>> ---
>>>  Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 15 +++++++++++----
>>>  1 file changed, 11 insertions(+), 4 deletions(-)
>> 
>> Acked-by: Rob Herring <robh@kernel.org>
>>
> Will you be picking up this change ?

Sure, done.
