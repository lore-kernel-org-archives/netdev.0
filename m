From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] extend stmmac DT support
Date: Thu, 04 Jul 2013 14:35:01 -0700 (PDT)
Message-ID: <20130704.143501.1841830283181488951.davem@davemloft.net>
References: <1372930496-18923-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	grant.likely@linaro.org, rob.herring@calxeda.com, rob@landley.net,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1372930496-18923-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu,  4 Jul 2013 10:34:56 +0100

> Thankyou for the comments on v1 patches.
> 
> This patch series adds support to new gmac versions 3.6.10 and 3.710, these
> versions of IP are integrated into ST STiH415/STiH416 SOCs.
> This patchset also adds phy reset capablity to stmmac-mdio driver via DT.
> 
> Changes since v1:
> 	- Fixed unused variable warings pointed by Dave M.
> 
> Changes since RFC:
> 	- re-use existing compatible strings to select right properties.
> 	- clean up reset callback support so that DT is not parsed everytime.

Series applied, thanks.
