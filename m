From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: stmmac: make reset control an optional
 requirement
Date: Sun, 08 Mar 2015 22:53:48 -0400 (EDT)
Message-ID: <20150308.225348.1529277180229125812.davem@davemloft.net>
References: <1425685708-12600-1-git-send-email-dinguyen@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, dinh.linux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vbridger@opensource.altera.com
To: dinguyen@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425685708-12600-1-git-send-email-dinguyen@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <dinguyen@opensource.altera.com>
Date: Fri, 6 Mar 2015 17:48:28 -0600

> From: Dinh Nguyen <dinguyen@opensource.altera.com>
> 
> Not having a reset control line to the ethernet controller should not be a
> hard failure. Instead, add support for deferred probing and just print out
> a debug statement.
> 
> Signed-off-by: Dinh Nguyen <dinguyen@opensource.altera.com>

Applied, thanks.
