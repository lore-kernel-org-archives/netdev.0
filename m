From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tlan: Fix bugs introduced by the last tlan cleanup
 patch
Date: Sun, 13 Feb 2011 10:55:34 -0800 (PST)
Message-ID: <20110213.105534.191390756.davem@davemloft.net>
References: <4D52F80E.9030307@iki.fi>
	<1297283106-10035-1-git-send-email-sakari.ailus@iki.fi>
	<4D56C08D.7060007@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sakari.ailus@iki.fi, netdev@vger.kernel.org, error27@gmail.com
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754663Ab1BMSy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 13:54:58 -0500
In-Reply-To: <4D56C08D.7060007@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Sat, 12 Feb 2011 18:17:01 +0100

> On 09/02/11 21:25, Sakari Ailus wrote:
>> Fix two bugs introduced by the patch "tlan: Code cleanup:
>> checkpatch.pl is
>> relatively happy now." In that patch, TLAN_CSTAT_READY was considered
>> as a
>> bit mask containing a single bit set while it was actually had two set
>> instead.
> 
> Commit ID of the referenced patch in net-net is
> c659c38b2796578638548b77ef626d93609ec8ac

I add this information to the commit message, applied, thanks.
