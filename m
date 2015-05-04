From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] drivers/net: include <module.h> for modular
 stmmac_platform code
Date: Sun, 03 May 2015 23:40:34 -0400 (EDT)
Message-ID: <20150503.234034.1502027656534456026.davem@davemloft.net>
References: <1430444867-22342-1-git-send-email-paul.gortmaker@windriver.com>
	<1430444867-22342-7-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430444867-22342-7-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 30 Apr 2015 21:47:42 -0400

> This file is built off of a tristate Kconfig option and also contains
> modular function calls so it should explicitly include module.h to
> avoid compile breakage during header shuffles done in the future.
> 
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
