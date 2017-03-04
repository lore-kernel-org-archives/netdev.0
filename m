From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] net: smsc: smc91x: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 4 Mar 2017 10:20:17 +0000
Message-ID: <20170304102017.GS21222@n2100.armlinux.org.uk>
References: <1488622292-13200-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@fluxnic.net, davem@davemloft.net, robert.jarzmik@free.fr,
        mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, fw@strlen.de, jeremy.linton@arm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1488622292-13200-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 04, 2017 at 11:11:32AM +0100, Philippe Reynes wrote:
>  
>  //		lp->port = cmd->port;

Hi,

Review looks good.  However, please also update the above comment as
well.

Thanks.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
