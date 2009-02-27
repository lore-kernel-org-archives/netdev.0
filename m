From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Fri, 27 Feb 2009 10:21:30 -0800
Message-ID: <c0a09e5c0902271021y3ba0f3b9r34e696e1e657cc61@mail.gmail.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	 <20090224.232814.227017310.davem@davemloft.net>
	 <c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
	 <20090227.000150.177646700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:5800 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbZB0SVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 13:21:32 -0500
Received: by wf-out-1314.google.com with SMTP id 28so1387981wfa.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 10:21:30 -0800 (PST)
In-Reply-To: <20090227.000150.177646700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 12:01 AM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Grover <andy.grover@gmail.com>
> Date: Wed, 25 Feb 2009 10:43:27 -0800
>
>> On Tue, Feb 24, 2009 at 11:28 PM, David Miller <davem@davemloft.net> wrote:
>> > Furthermore the port you've choosen for the protocol is arbitrary, not
>> > properly allocated with the appropriate standards committee, and
>> > therefore could conflict with something other people are using.
>>
>> I'm sure allocating the port won't be too big an issue.
>
> Ok, I added the RDS code to the net-next-2.6 tree, changing
> AF_RDS to be 21

Thanks much!

-- Andy
