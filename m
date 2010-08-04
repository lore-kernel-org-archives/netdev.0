From: Rick Jones <rick.jones2@hp.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Tue, 03 Aug 2010 18:17:46 -0700
Message-ID: <4C58BFBA.8010503@hp.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com> 	<4C58B4B4.6010904@hp.com> <AANLkTikqTHNmTQL2-QSJZmJ=18CfdZGo41zUE6mKO_PS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:22136 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757955Ab0HDBRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 21:17:49 -0400
In-Reply-To: <AANLkTikqTHNmTQL2-QSJZmJ=18CfdZGo41zUE6mKO_PS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jack Zhang wrote:
> Hi Rick,
> 
> Thanks for your reply.
> 
> Do you maybe know which part of the source code implements the details
> about how much send buffer can actually be used for the data payload?

Specifically no. I've not had to go looking for it.

happy benchmarking,

rick jones
