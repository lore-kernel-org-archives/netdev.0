From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH v2 0/4] USB support for Broadcom NSP SoC
Date: Fri, 27 Jan 2017 13:09:22 +0530
Message-ID: <588AF92A.4060802@ti.com>
References: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
 <588A16FA.50507@ti.com> <241009ca-4b34-b160-2de1-4752d3ff114b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, Yendapally Reddy Dhananjaya Reddy
 <yendapally.reddy@broadcom.com>, Rob Herring <robh+dt@kernel.org>, Mark
 Rutland <mark.rutland@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ray Jui <rjui@broadcom.com>,
 Scott Branden <sbranden@broadcom.com>, Jon Mason <jonmason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <241009ca-4b34-b160-2de1-4752d3ff114b@gmail.com>
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

Hi,

On Thursday 26 January 2017 10:57 PM, Florian Fainelli wrote:
> On 01/26/2017 07:34 AM, Kishon Vijay Abraham I wrote:
>>
>>
>> On Tuesday 17 January 2017 09:44 PM, Yendapally Reddy Dhananjaya Reddy wrote:
>>> This patch set contains the usb support for Broadcom NSP SoC. The
>>> usb3 phy is internal to the SoC and is accessed through mdio interface.
>>> The mdio interface can be used to access either internal usb3 phy or
>>> external ethernet phy using a multiplexer.
>>>
>>> The first patch provides the documentation details for usb3 phy. The
>>> second patch provides the changes to the mdio bus driver. The third
>>> patch provides the phy driver and fourth patch provides the enable
>>> method for usb.
>>
>> merged the 1st and 4th patch to linux-phy.
> 
> You mean 1st and 3rd here, right? 4th is a Device Tree change that I
> should take, and Patch 2 should be merged by David.

yeah, sorry!
> 
> What branch in your tree should we be looking at?

git://git.kernel.org/pub/scm/linux/kernel/git/kishon/linux-phy.git next

Thanks
Kishon
