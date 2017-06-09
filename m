From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2(net.git)] stmmac: fix ptp header for GMAC3 hw
 timestamp
Date: Fri, 09 Jun 2017 12:39:53 -0400 (EDT)
Message-ID: <20170609.123953.1175542442917993885.davem@davemloft.net>
References: <trinity-0deb7b33-2ac6-4e6d-9e43-c5feb0c09e14-1496957473112@3capp-webde-bs49>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mario_Molitor@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <trinity-0deb7b33-2ac6-4e6d-9e43-c5feb0c09e14-1496957473112@3capp-webde-bs49>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mario Molitor" <Mario_Molitor@web.de>
Date: Thu, 8 Jun 2017 23:31:13 +0200

> From ce9c334037fce37ccd715124cda57d1fd6d8cfe8 Mon Sep 17 00:00:00 2001
> From: Mario Molitor <mario_molitor@web.de>
> Date: Thu, 8 Jun 2017 22:41:02 +0200
> Subject: [PATCH 1/2] stmmac: fix ptp header for GMAC3 hw timestamp
> 
> According the CYCLON V documention only the bit 16 of snaptypesel should
> set.
> (more information see Table 17-20 (cv_5v4.pdf) :
>  Timestamp Snapshot Dependency on Register Bits)
> 
> Fixes: d2042052a0aa ("stmmac: update the PTP header file")
> Signed-off-by: Mario Molitor <mario_molitor@web.de>

Applied.
