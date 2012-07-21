From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: how routing table maintained
Date: Sat, 21 Jul 2012 19:58:22 +0200
Message-ID: <500AEDBE.4000907@computer.org>
References: <4A71D24947E78D43BC584A7CD4391A41017DD9AB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:3409 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab2GUSBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 14:01:23 -0400
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DD9AB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2012 02:41 PM, BALAKUMARAN KANNAN wrote:
> I want to know how routing table and routing cache is maintained.
> I can find some entries in cache even after the route is deleted
> from the routing table. Is it possible to delete an entry(the
> particular entry or flush the entire cache) from the cache once
> it is deleted from the main routing table.

Kannan,

Please be aware that David Miller is on a quest to obliterate the route cache. He has recently sent patches to do just that.

HTH, Jan
