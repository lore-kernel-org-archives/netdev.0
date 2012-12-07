From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: smsc: force all capable mode if the phy
 is started in powerdown mode
Date: Fri, 07 Dec 2012 12:48:35 -0500 (EST)
Message-ID: <20121207.124835.728462205614919465.davem@davemloft.net>
References: <1354647130-1854-1-git-send-email-tremyfr@yahoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	otavio@ossystems.com.br, javier@dowhile0.org, jkosina@suse.cz,
	eric.jarrige@armadeus.org, julien.boibessot@armadeus.com,
	thomas.petazzoni@free-electrons.com
To: tremyfr@yahoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354647130-1854-1-git-send-email-tremyfr@yahoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@yahoo.fr>
Date: Tue,  4 Dec 2012 19:52:10 +0100

> A SMSC PHY in power down mode can't be used.
> If a SMSC PHY is in this mode in the config_init
> stage, the mode "all capable" is set. So the PHY
> could then be used.
> 
> Signed-off-by: Philippe Reynes <tremyfr@yahoo.fr>

Applied, thanks.
