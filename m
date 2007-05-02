From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: ARP Spoofing
Date: Wed, 02 May 2007 14:39:04 -0600
Message-ID: <4638F6E8.3060609@nortel.com>
References: <4638CDED.4020100@cs.byu.edu> <4638DEB9.90608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Topher Fischer <javert42@cs.byu.edu>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:45270 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766996AbXEBUjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 16:39:13 -0400
In-Reply-To: <4638DEB9.90608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:

> If by arp spoofing you mean receiving arp replies from multiple sources and
> trusting all of them, then I haven't seen anything.
> 
> I don't know the history as to why nothing has has been done.

This concept is a valuable tool to allow for fast publishing of IP 
address takeover in redundant-server situations.

There are ways in which it can be misused, but that doesn't make it an 
invalid technique.

Chris
