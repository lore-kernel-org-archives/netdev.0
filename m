From: David Miller <davem@davemloft.net>
Subject: Re: [Bug-Fix][Patch 1/1] dccp: fix oops on Reset after close
Date: Tue, 01 Mar 2011 23:02:20 -0800 (PST)
Message-ID: <20110301.230220.189699042.davem@davemloft.net>
References: <20110302063447.GB4902@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhovold@gmail.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946Ab1CBHBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 02:01:43 -0500
In-Reply-To: <20110302063447.GB4902@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 2 Mar 2011 07:34:47 +0100

> could you please apply the below bug fix for a condition where a simple packet
> reception can trigger oops.

Applied, thanks Gerrit.
