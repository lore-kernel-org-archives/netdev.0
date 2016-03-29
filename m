From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3.16]r9169: Correct Set Vlan tag
Date: Tue, 29 Mar 2016 16:59:43 -0400 (EDT)
Message-ID: <20160329.165943.1444638018201199679.davem@davemloft.net>
References: <1459240400-1602-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbcC2U7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 16:59:45 -0400
In-Reply-To: <1459240400-1602-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Tue, 29 Mar 2016 11:33:20 +0300

>  This patch add set Vlan tag and flush CPlusCmd register because when unset
>  RxVlan and RxChkSum bit, whithout some explication , unwanted bits
>  is set, PCIDAC, PCIMulRW  and others.Whithout this patch when run
>  ethtool -d eth0 on "C+ Command" field missing "VLAN de-tagging"
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>

I am hereby blocking you from making any and all postings to the
mailing lists at vger.kernel.org

There is not negotiating about this, all complaints sent to me will be
ignored.  You should have thought about the consequences of your
actions (or lack thereof) over the past several months.

You cannot continually post patches, as you please, and completely
refuse to interact with the developers who review your changes and
give you feedback.

You have not coherently replied to any feedback you have been given.

You have almost always ignored the feedback you were given and
continued to make the same undesirable changes over and over again.

And you refuse to even acknowledge or address the issue of your
interactions with the community in any way whatsoever.

Therefore you are hurting development, and wasting precious developer
resources with your postings.

All of this is unacceptable.

But that all ends right now.

Thank you.
