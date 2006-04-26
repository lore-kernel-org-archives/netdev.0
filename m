From: Zach Brown <zach.brown@oracle.com>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 16:25:16 -0700
Message-ID: <4450015C.1070502@oracle.com>
References: <44493980.1040708@oracle.com>	<444E31D9.1010705@psc.edu> <20060426.144540.39973302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56461 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1751029AbWDZX0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 19:26:00 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060426.144540.39973302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> Given that RFC2681 is Experimental (and I'm not aware of any current 
>> efforts in the IETF to push it to the standard track), IHMO it would not 
>> be inappropriate to make this behavior controlled via sysctl.
> 
> I have to respectfully disagree.

OK, thanks for taking the time to look at it.

- z
