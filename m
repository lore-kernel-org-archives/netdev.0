From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 0/3] ARM: dts: keystone-k2g: Add DCAN instances to 66AK2G
Date: Thu, 10 Aug 2017 09:51:44 -0700
Message-ID: <76400dbd-2970-a5bc-d994-3cc7933c8496@oracle.com>
References: <20170802201822.11532-1-fcooper@ti.com>
 <69995971-2fe7-87f4-a46a-8ef4f729ffc5@oracle.com>
 <8930852b-6995-3d41-440e-86f440b313ad@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>, wg@grandegger.com,
 mkl@pengutronix.de, robh+dt@kernel.org, ssantosh@kernel.org,
 linux@armlinux.org.uk, linux-can@vger.kernel.org,
 netdev@vger.kernel.org, devicetree@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <8930852b-6995-3d41-440e-86f440b313ad@ti.com>
Content-Language: en-US
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

On 8/7/17 2:31 PM, Franklin S Cooper Jr wrote:
> 
> Hi Santosh,
> On 08/04/2017 12:07 PM, Santosh Shilimkar wrote:
>> Hi Franklin,
>>
>> On 8/2/2017 1:18 PM, Franklin S Cooper Jr wrote:
>>> Add D CAN nodes to 66AK2G based SoC dtsi.
>>>
>>> Franklin S Cooper Jr (2):
>>>     dt-bindings: net: c_can: Update binding for clock and power-domains
>>>       property
>>>     ARM: configs: keystone: Enable D_CAN driver
>>>
>>> Lokesh Vutla (1):
>>>     ARM: dts: k2g: Add DCAN nodes
>>>
>> Any DCAN driver dependency with these patchset ? If not, I can
>> queue this up so do let me know.
> 
> There aren't any dependencies.

Applied. Thanks !!

Regards,
Santosh
