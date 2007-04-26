From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 26 Apr 2007 20:49:15 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704262048510.506@yvahk01.tjqt.qr>
References: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754846AbXDZTBZ@vger.kernel.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Apr 25 2007 10:45, Waskiewicz Jr, Peter P wrote:
>> 
>> BTW, is there any reason this is being cced to lkml?
>
>Since this change affects how tc interacts with the qdisc layer, I cced
>lkml.

Fine with me, at least I get to know that tc could break :)



Jan
-- 
