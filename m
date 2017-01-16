From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH 0/6] USB support for Broadcom NSP SoC
Date: Mon, 16 Jan 2017 14:47:46 +0530
Message-ID: <587C8FBA.7010802@ti.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
 <79483fc3-5e91-a1f0-1dbf-1987682373e6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, Yendapally Reddy Dhananjaya Reddy
 <yendapally.reddy@broadcom.com>, Rob Herring <robh+dt@kernel.org>, Mark
 Rutland <mark.rutland@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ray Jui <rjui@broadcom.com>,
 Scott Branden <sbranden@broadcom.com>, Jon Mason <jonmason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <79483fc3-5e91-a1f0-1dbf-1987682373e6@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On Tuesday 13 December 2016 07:50 AM, Florian Fainelli wrote:
> On 11/09/2016 01:33 AM, Yendapally Reddy Dhananjaya Reddy wrote:
>> This patch set contains the usb support for Broadcom NSP SoC.
>> The usb phy is connected through mdio interface. The mdio interface
>> can be used to access either internal phys or external phys using a
>> multiplexer.
>>
>> The first patch provides the documentation details for mdio-mux and
>> second patch provides the documentation details for usb3 phy. The third
>> patch contains the mdio-mux support and fourth patch contains the
>> changes to the mdio bus driver.
>>
>> The fifth patch provides the phy driver and sixth patch provides the
>> enable method for usb.
>>
>> This patch series has been tested on NSP bcm958625HR board.
>> This patch series is based on v4.9.0-rc1 and is available from github-
>> repo: https://github.com/Broadcom/cygnus-linux.git
>> branch:nsp-usb-v1
> 
> Can you resubmit this patch series with the feedback from Andrew, Rob
> and Scott addressed?

can the phy patches be re-submitted based on latest mainline and addressing
those feedbacks?

Thanks
Kishon
