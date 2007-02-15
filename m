From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 21:13:35 +0100
Message-ID: <87mz3ftc0g.fsf@kruemel.my-eitzenberger.de>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
	<20070215112654.40850708@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:53905 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161140AbXBOUN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 15:13:56 -0500
In-Reply-To: <20070215112654.40850708@freekitty> (Stephen Hemminger's
 message of "Thu, 15 Feb 2007 11:26:54 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

>> I used both use_carrier=1 (default) as well as miimon=50 without luck.
>
> use_carrier should work (since device reports carrier transistions).

As you can see in the script I used both use_carrier and miimon (in
combinations) without success.  In fact use_carrier is the default if no
other options are set.

  /holger
