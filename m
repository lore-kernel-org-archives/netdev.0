From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 15:06:54 -0600
Message-ID: <4F3ACCEE.6070701@genband.com>
References: <201202132253.16496.jdelvare@suse.de> <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F3AA779.3080409@hp.com> <201202142027.13147.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:54106 "EHLO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761222Ab2BNVIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:08:01 -0500
In-Reply-To: <201202142027.13147.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2012 01:27 PM, Jean Delvare wrote:

> Without the patch above, doing bonding on top of 3c59x is simply not
> possible, at least not in active-backup mode. For other modes it depends
> if you are only interested in load balancing or also on redundancy.

Could you just use arp monitoring instead of mii?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
