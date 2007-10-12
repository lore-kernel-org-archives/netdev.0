From: John Heffner <jheffner@psc.edu>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 18:22:57 -0700
Message-ID: <470ECC71.1070303@psc.edu>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com><20071011.163737.36654032.davem@davemloft.net><470EB6D6.9020704@hp.com> <20071011.170244.32082446.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com> <470EBD2C.8020704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54652 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638AbXJLBXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 21:23:11 -0400
In-Reply-To: <470EBD2C.8020704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I just tried turning off my explicit SO_SNDBUF/SO_RCVBUG settings in my 
> app,
> and the connection ran very poorly through a link with even a small
> bit of latency (~2-4ms I believe).

I often run at full gigabit or faster with latencies of 100+ ms.  Can 
you give a bit more detail?

   -John
