From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: stmmac: dwmac-oxnas: fix leaks and
 simplify pm
Date: Tue, 03 Jan 2017 09:33:30 -0500 (EST)
Message-ID: <20170103.093330.1186420950091624982.davem@davemloft.net>
References: <20170102115604.32482-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        narmstrong@baylibre.com, netdev@vger.kernel.org,
        linux-oxnas@lists.tuxfamily.org, linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102115604.32482-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Mon,  2 Jan 2017 12:56:01 +0100

> These patches fixes of-node and fixed-phydev leaks in the recently added
> dwmac-oxnas driver, and ultimately switches over to using the generic pm
> implementation as the required callbacks are now in place.

Series applied.
