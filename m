From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix skb_seq_read returning wrong offset/length
 for page frag data
Date: Mon, 18 May 2009 19:40:47 -0700 (PDT)
Message-ID: <20090518.194047.77071994.davem@davemloft.net>
References: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
	<46A00B48CC54E4468EF6911F877AC4CA02294B56@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Thomas_Chenault@Dell.com, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753440AbZESCkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:40:49 -0400
In-Reply-To: <46A00B48CC54E4468EF6911F877AC4CA02294B56@blrx3m10.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Shyam_Iyer@Dell.com>
Date: Mon, 18 May 2009 18:32:29 +0530

> Dave - Does this patch needs more review or you want to queue it up to
> your tree? I believe it is a critical bug fix.

I just got back from a week of being away on a cruise, so don't
worry it's in my backlog.
