From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Tue, 07 Nov 2006 13:58:31 -0500
Message-ID: <20061107185830.GT2667@mathom.us>
References: <20061005224949.456192755@osdl.org>
 <20061005225209.769741968@osdl.org> <20061107132506.GS2667@mathom.us>
 <20061107095104.734326cc@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:4946 "EHLO
	vms040pub.verizon.net") by vger.kernel.org with ESMTP
	id S1751085AbWKGTJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 14:09:05 -0500
Received: from osgiliath.mathom.us ([71.246.251.8])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0J8D00LK9JDM3YI3@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 07 Nov 2006 12:58:35 -0600 (CST)
In-reply-to: <20061107095104.734326cc@freekitty>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 09:51:04AM -0800, Stephen Hemminger wrote:
>Which form of bonding link checking are you using. It could be that
>bonding MII checking is confused.

I'm not specifying anything, just "ifenslave bond0 eth2 eth3"

Mike Stone
