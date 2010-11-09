From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] vxge: enable rxhash
Date: Mon, 08 Nov 2010 18:38:06 -0800 (PST)
Message-ID: <20101108.183806.193724928.davem@davemloft.net>
References: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
	<20101108.124452.115944240.davem@davemloft.net>
	<20101108225340.GA16247@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sivakumar.Subramani@exar.com,
	Sreenivasa.Honnur@exar.com, Ramkrishna.Vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752992Ab0KIChm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 21:37:42 -0500
In-Reply-To: <20101108225340.GA16247@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Mon, 8 Nov 2010 16:53:40 -0600

> On Mon, Nov 08, 2010 at 12:44:52PM -0800, David Miller wrote:
>> 
>> This patch set doesn't apply at all to the current tree, please
>> respin them, thanks.
> 
> When I sent out the series on Thursday, the tree did not have
> "vxge: make functions local and remove dead code".  When that patch
> was originally released (Oct 15), I asked for it to not be included as
> it would break soon-to-be-released patch series.  I did not see any
> e-mail afterward, so I assumed this was acceptable to you.  We then
> ran the driver though our internal tests to verify its functionality,
> which would need to be re-done if the patches are respun.
> 
> I have a reworked version of that patch which can be applied after
> this patch series.  Is it acceptable to you to revert the commit,
> apply the series, then apply the modified version of the "local
> functions" patch?  I have already sniff tested it on our hardware
> without issues.

Ummm, no.  I'm not reverting a correct patch just so that your
original patches apply properly.

Please just respin the patch series on top of the current tree.
