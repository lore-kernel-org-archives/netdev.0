From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: stmmac: fix maxmtu assignment to be within
 valid range
Date: Sun, 08 Jan 2017 18:20:54 -0500 (EST)
Message-ID: <20170108.182054.1682582856001870028.davem@davemloft.net>
References: <1483781523-14334-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        seraphin.bonnaffe@st.com, jarod@redhat.com,
        andy.shevchenko@gmail.com, alexandre.torgue@gmail.com,
        manabian@gmail.com, niklas.cassel@axis.com, johan@kernel.org,
        pavel@ucw.cz, lars.persson@axis.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483781523-14334-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong"	<hock.leong.kweh@intel.com>
Date: Sat,  7 Jan 2017 17:32:03 +0800

> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> There is no checking valid value of maxmtu when getting it from
> device tree. This resolution added the checking condition to
> ensure the assignment is made within a valid range.
> 
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

Applied, thank you.
