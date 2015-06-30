From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 16:52:45 +0300
Message-ID: <55929F2D.9050805@mellanox.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
 <5592913C.3000207@mellanox.com>
 <alpine.LFD.2.11.1506301520180.1799@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	<netdev@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0079.outbound.protection.outlook.com ([157.56.112.79]:14608
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752637AbbF3Nwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 09:52:34 -0400
In-Reply-To: <alpine.LFD.2.11.1506301520180.1799@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2015 4:24 PM, Sebastian Ott wrote:
>> >Do you run the VF on the same system/kernel as the PF, or the VF is probed to
>> >VM which runs the latest kernel and the PF runsolder kernel (which?)
> The latter case. The PF is driven by a much older Kernel running OFED 2.3.2.0.0.1
>

Can you try running the inbox PF driver that comes with the PF kernel 
(what kernel is that?) I'd like to see we're OK there.

Or.
