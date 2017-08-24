From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: stmmac: Delete dead code for MDIO
 registration
Date: Thu, 24 Aug 2017 09:36:05 -0700 (PDT)
Message-ID: <20170824.093605.1123551429403886787.davem@davemloft.net>
References: <20170824070317.10265-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: romain.perier@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824070317.10265-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>
Date: Thu, 24 Aug 2017 09:03:17 +0200

> This code is no longer used, the logging function was changed by commit
> fbca164776e4 ("net: stmmac: Use the right logging functi").

You're truncating the commit header text here too, please fix this.
