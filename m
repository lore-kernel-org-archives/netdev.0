From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH 1/1] tlan: Fix bugs introduced by the last tlan cleanup
 patch
Date: Sat, 12 Feb 2011 18:17:01 +0100
Message-ID: <4D56C08D.7060007@computer.org>
References: <4D52F80E.9030307@iki.fi> <1297283106-10035-1-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, error27@gmail.com
To: Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:24581 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751309Ab1BLRR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 12:17:28 -0500
In-Reply-To: <1297283106-10035-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/11 21:25, Sakari Ailus wrote:
> Fix two bugs introduced by the patch "tlan: Code cleanup: checkpatch.pl is
> relatively happy now." In that patch, TLAN_CSTAT_READY was considered as a
> bit mask containing a single bit set while it was actually had two set
> instead.

Commit ID of the referenced patch in net-net is 
c659c38b2796578638548b77ef626d93609ec8ac
