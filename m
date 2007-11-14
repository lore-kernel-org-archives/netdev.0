From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Wed, 14 Nov 2007 10:48:43 +0100
Message-ID: <473AC47B.9070509@trash.net>
References: <20071108143205.GA22490@mpi-sb.mpg.de> <47332F1F.5040401@trash.net> <20071114084420.GA29241@mpi-sb.mpg.de> <473AB82F.8050801@trash.net> <20071114094508.GA6004@mpi-sb.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pcernko@mpi-sws.mpg.de
To: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39455 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbXKNJsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:48:54 -0500
In-Reply-To: <20071114094508.GA6004@mpi-sb.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Jochem wrote:
> 
>> I don't think its very useful since you can simply get this information
>> from /proc/cmdline in case something goes wrong, but if you insist at
>> least give it a meaningful prefix.
> 
> Added.
> 
>> The initialization is unnecessary.
> 
> Removed.
> 
>> Should be >= I think.
> 
> Fixed.


Looks fine, thanks.


