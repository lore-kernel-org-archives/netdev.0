From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 0/3] ARM: dts: keystone-k2g: Add DCAN instances to 66AK2G
Date: Fri, 4 Aug 2017 10:07:57 -0700
Message-ID: <69995971-2fe7-87f4-a46a-8ef4f729ffc5@oracle.com>
References: <20170802201822.11532-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>, wg@grandegger.com,
 mkl@pengutronix.de, robh+dt@kernel.org, ssantosh@kernel.org,
 linux@armlinux.org.uk, linux-can@vger.kernel.org,
 netdev@vger.kernel.org, devicetree@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170802201822.11532-1-fcooper@ti.com>
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

Hi Franklin,

On 8/2/2017 1:18 PM, Franklin S Cooper Jr wrote:
> Add D CAN nodes to 66AK2G based SoC dtsi.
> 
> Franklin S Cooper Jr (2):
>    dt-bindings: net: c_can: Update binding for clock and power-domains
>      property
>    ARM: configs: keystone: Enable D_CAN driver
> 
> Lokesh Vutla (1):
>    ARM: dts: k2g: Add DCAN nodes
> 
Any DCAN driver dependency with these patchset ? If not, I can
queue this up so do let me know.

Regards,
Santosh
