From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/12] stmmac: fix platform driver unregistering
Date: Fri, 14 Dec 2012 13:16:26 -0500 (EST)
Message-ID: <20121214.131626.1070000941381130402.davem@davemloft.net>
References: <20121214110229.11019.63713.stgit@zurg>
	<20121214110251.11019.9914.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110251.11019.9914.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 14 Dec 2012 15:02:51 +0400

> This patch fixes platform device drivers unregistering and adds proper error
> handing on module loading.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied.
