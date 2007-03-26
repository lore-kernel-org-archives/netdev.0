From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Mon, 26 Mar 2007 10:22:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0703261020430.534@pcgl.dsa-ac.de>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
 <Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de> <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
 <20070324003608.GB4494@sortiz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	Paul Mackerras <paulus@samba.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:57725 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933683AbXCZIWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 04:22:25 -0400
In-Reply-To: <20070324003608.GB4494@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 24 Mar 2007, Samuel Ortiz wrote:

> On Fri, Mar 23, 2007 at 01:14:43PM +0100, Guennadi Liakhovetski wrote:
>
>> Below is a patch that fixes ONE
>> sk_buff leak (maintainer added to cc: hi, Paul:-)). Still investigating if
>> there are more there.
> Are you still seeing the skb cache growing with your fix ?

No, running stable so far.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
