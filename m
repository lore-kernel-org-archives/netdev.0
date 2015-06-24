From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] stmmac: troubleshoot unexpected bits in des0 & des1
Date: Wed, 24 Jun 2015 02:39:08 -0700 (PDT)
Message-ID: <20150624.023908.1017811354688857624.davem@davemloft.net>
References: <1435135661-24359-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1435135661-24359-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed, 24 Jun 2015 11:47:41 +0300

> Current implementation of descriptor init procedure only takes
> care about setting/clearing ownership flag in "des0"/"des1"
> fields while it is perfectly possible to get unexpected bits
> set because of the following factors:

Applied.
