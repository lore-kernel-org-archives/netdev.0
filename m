From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/2] Renesas Ethernet AVB driver proper
Date: Thu, 11 Jun 2015 00:14:50 -0700 (PDT)
Message-ID: <20150611.001450.896536559764289809.davem@davemloft.net>
References: <1890562.JASeYkKSbr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1890562.JASeYkKSbr@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 11 Jun 2015 01:01:43 +0300

> Ethernet AVB includes an Gigabit Ethernet controller (E-MAC) that is basically
> compatible with SuperH Gigabit Ethernet E-MAC.  Ethernet AVB has  a  dedicated
> direct memory access controller (AVB-DMAC) that is a new design compared to the
> SuperH E-DMAC. The AVB-DMAC is compliant with 3 standards formulated for IEEE
> 802.1BA: IEEE 802.1AS timing and synchronization protocol, IEEE 802.1Qav real-
> time transfer, and the IEEE 802.1Qat stream reservation protocol.
> 
> The  driver only supports device tree probing, so the binding document is
> included in this patch.
> 
> Based on the original patches by Mitsuhiro Kimura.
> 
> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
