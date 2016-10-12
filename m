From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: stmmac: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 12 Oct 2016 01:41:34 -0400 (EDT)
Message-ID: <20161012.014134.1167566195936685797.davem@davemloft.net>
References: <1475476100-28219-1-git-send-email-tremyfr@gmail.com>
        <1475476100-28219-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475476100-28219-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon,  3 Oct 2016 08:28:20 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
