From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] sweep the floors and convert some
 .get_drvinfo routines to strlcpy
Date: Tue, 08 Nov 2011 15:17:46 -0500 (EST)
Message-ID: <20111108.151746.1961969455753450861.davem@davemloft.net>
References: <20111107232927.ADF412900440@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave@thedillows.org,
	klassert@mathematik.tu-chemnitz.de, ionut@badula.org,
	jcliburn@gmail.com, chris.snook@gmail.com, mchan@broadcom.com,
	eilong@broadcom.com, mcarlson@broadcom.com, rmody@brocade.com,
	grundler@parisc-linux.org, ajit.khaparde@emulex.com,
	buytenh@wantstofly.org, shemminger@linux-foundation.org,
	thockin@hockin.org, jdmason@kudzu.us, sony.chacko@qlogic.com,
	anirban.chakraborty@qlogic.com, romieu@fr.zoreil.com,
	steve.glendinning@smsc.com
To: raj@tardy.cup.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab1KHUXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 15:23:23 -0500
In-Reply-To: <20111107232927.ADF412900440@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Mon,  7 Nov 2011 15:29:27 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Per the mention made by Ben Hutchings that strlcpy is now the preferred
> string copy routine for a .get_drvinfo routine, do a bit of floor
> sweeping and convert some of the as-yet unconverted ethernet drivers to
> it.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied.
