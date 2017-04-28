From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Fri, 28 Apr 2017 12:09:37 -0400 (EDT)
Message-ID: <20170428.120937.92547018334978113.davem@davemloft.net>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sascha.weisenberger@siemens.com
To: jan.kiszka@siemens.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Mon, 24 Apr 2017 21:27:15 +0200

> The IOT2000 is industrial controller platform, derived from the Intel
> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
> IOT2040 has two of them. They can be told apart based on the board asset
> tag in the DMI table.
> 
> Based on patch by Sascha Weisenberger.
> 
> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>

It looks like there is still some discussion going on about precise
detection and disambiguation of these devices.

Once things have settled down please resubmit the final patch.

Thank you.
