From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Mon, 13 Sep 2010 11:46:00 -0400
Message-ID: <4C8E4738.3040809@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <4C8950D4.9060102@criticallink.com> <201009101823.52755.caglarakyuz@gmail.com> <201009111154.42171.caglarakyuz@gmail.com> <4C8E308B.7020003@ti.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Caglar Akyuz <caglarakyuz@gmail.com>,
	Michael Williamson <michael.williamson@criticallink.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: "Chemparathy, Cyril" <cyril@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C8E308B.7020003@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Caglar,

[...]
> Assuming that the DMA got stuck at some point leading up to the transmit
> timeout, any ideas as to why a host error was not thrown?  To help
> debug, I'll post out a set of patches that dump out the MAC (and DMA)
> registers on timeout.  That should give us some visibility into the problem.

I have posted a couple of additional patches for this on [1].  Would you
mind giving these a quick try?  The register dumps should prove useful
in figuring this out.

Regards
Cyril.

[1]
http://arago-project.org/git/people/?p=cyril/linux-tnetv107x.git;a=shortlog;h=refs/heads/emac-cpdma-mdio-fixes
