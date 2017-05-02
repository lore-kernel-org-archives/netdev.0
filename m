From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 02 May 2017 15:31:38 -0400 (EDT)
Message-ID: <20170502.153138.2195637581927929977.davem@davemloft.net>
References: <aa7a7f82-7933-1a97-12c4-b51efab498c9@siemens.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sascha.weisenberger@siemens.com, andy.shevchenko@gmail.com
To: jan.kiszka@siemens.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa7a7f82-7933-1a97-12c4-b51efab498c9@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Tue, 2 May 2017 09:58:00 +0200

> The IOT2000 is industrial controller platform, derived from the Intel
> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
> IOT2040 has two of them. They can be told apart based on the board asset
> tag in the DMI table.
> 
> Based on patch by Sascha Weisenberger.
> 
> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>
> ---
> 
> Changes in v2:
> - reformatted match conditions [Andy]

Applied, thanks.
