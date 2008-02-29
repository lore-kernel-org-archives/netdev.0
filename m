From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/4][SCTP]: Use proc_create to setup
 de->proc_fops.
Date: Fri, 29 Feb 2008 11:26:17 -0800 (PST)
Message-ID: <20080229.112617.157370390.davem@davemloft.net>
References: <47C80BD5.7090700@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43234
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752955AbYB2T0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:26:21 -0500
In-Reply-To: <47C80BD5.7090700@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 29 Feb 2008 16:42:45 +0300

> In addition to commit 160f17 use proc_create in two more places.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6

Please please please, when referencing commits DO NOT provide
only the SHA ID, provide the headline of the commit log as
well because when patches move around trees the IDs change.

I do this for a lot of people lately, please help lessen my
load by taking care of this yourselves.

For example, the new commit log for this change here is now:

    [SCTP]: Use proc_create to setup de->proc_fops.
    
    In addition to commit 160f17 ("[SCTP]: Use proc_create() to setup
    ->proc_fops first") use proc_create in two more places.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks.
