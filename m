From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2(net.git)] stmmac: fix for hw timestamp of GMAC3 unit
Date: Wed, 07 Jun 2017 15:13:58 -0400 (EDT)
Message-ID: <20170607.151358.2259849914410908503.davem@davemloft.net>
References: <trinity-988824f2-9aed-4ed0-bc97-d78b13337cf5-1496825121649@3capp-webde-bs41>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mario_Molitor@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <trinity-988824f2-9aed-4ed0-bc97-d78b13337cf5-1496825121649@3capp-webde-bs41>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mario Molitor" <Mario_Molitor@web.de>
Date: Wed, 7 Jun 2017 10:45:21 +0200

> fixed: commit ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")

The correct tag string is "Fixes: " not "fixed: "

Also, the word "commit" should not be there.

Please fix this in both of your patches.
