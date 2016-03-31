From: Robert Gadsdon <rhgadsdon@gmail.com>
Subject: Re: [PATCH] stmmac: Fix phy without MDIO subnode
Date: Thu, 31 Mar 2016 10:30:14 -0700
Message-ID: <56FD5EA6.6040206@gmail.com>
References: <1458817012-14293-1-git-send-email-john@metanate.com>
 <56F3E3E2.6070001@st.com> <20160324170119.28d54ed5.john@metanate.com>
 <56F4F9F6.8070103@st.com> <56FC1972.9050704@gmail.com>
 <56FCD459.2040406@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	John Keeping <john@metanate.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FCD459.2040406@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A have applied the 'STMMAC: fix TX normal DESC' patch (from netdev) as
well as the 'stmmac: Fix phy without MDIO subnode' patch, and the Rock2
Ethernet link now works correctly (Kernel 4.6-rc1)

Thanks..

Robert Gadsdon.
