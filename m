From: John Heffner <jheffner@psc.edu>
Subject: Re: SACK scoreboard
Date: Wed, 09 Jan 2008 09:56:16 -0500
Message-ID: <4784E090.8080303@psc.edu>
References: <20080108.144456.173014334.davem@davemloft.net>	<p73sl17pwfy.fsf@bingen.suse.de>	<47844D1C.1060706@psc.edu> <20080108.224144.234253941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:62111 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbYAIO4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 09:56:33 -0500
In-Reply-To: <20080108.224144.234253941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 08 Jan 2008 23:27:08 -0500
> 
>> I also wonder how much of a problem this is (for now, with window sizes 
>> of order 10000 packets.  My understanding is that the biggest problems 
>> arise from O(N^2) time for recovery because every ack was expensive. 
>> Have current tests shown the final ack to be a major source of problems?
> 
> Yes, several people have reported this.

I may have missed some of this.  Does anyone have a link to some recent 
data?

   -John
