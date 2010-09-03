From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v2 00/10] split out emac cpdma and mdio for reuse
Date: Fri, 03 Sep 2010 14:20:47 -0400
Message-ID: <4C813C7F.5090602@ti.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com> <87eida3fl9.fsf@deeprootsystems.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"Ramirez Luna, Omar" <omar.ramirez@ti.com>,
	"Parrot, Benoit" <bparrot@ti.com>
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <87eida3fl9.fsf@deeprootsystems.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kevin,

[...]
>> Although am3517 (omap) board support code has been updated as needed,
>> emac does not work on this platform.
> 
> Just to clarify... did EMAC work on AM3517 before this series?

No.  It didn't work before this series.  To get AM3517 EMAC working, the
driver needs another patch to enable the interface clock in addition to
the functional clock.

Regards
Cyril.
