From: David Miller <davem@davemloft.net>
Subject: Re: stmmac: fix phy naming inconsistency
Date: Tue, 24 Jan 2012 15:29:52 -0500 (EST)
Message-ID: <20120124.152952.59640686729726715.davem@davemloft.net>
References: <20120124092648.GA26380@mail.gnudd.com>
	<4F1E90B6.6090106@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rubini@gnudd.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, giancarlo.asnaghi@st.com,
	peppe.cavallaro@st.com
To: florian@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F1E90B6.6090106@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 24 Jan 2012 12:06:30 +0100

> Hello Alessandro,
> 
> On 01/24/12 10:26, Alessandro Rubini wrote:
>> After commit "db8857b stmmac: use an unique MDIO bus name" my
>> device stopped being probed because two different names were being
>> used in different places. This fixes the inconsistency.
>>
>> Signed-off-by: Alessandro Rubini<rubini@gnudd.com>
>> Acked-by: Giancarlo Asnaghi<giancarlo.asnaghi@st.com>
>> Cc: Giuseppe Cavallaro<peppe.cavallaro@st.com>
>> Cc: Florian Fainelli<florian@openwrt.org>
> 
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
