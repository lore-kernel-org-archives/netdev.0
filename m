From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 21:32:23 +0300
Message-ID: <20090106183223.GA11964@ioremap.net>
References: <20081224152841.GB13113@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:55596 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbZAFSc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 13:32:26 -0500
Content-Disposition: inline
In-Reply-To: <20081224152841.GB13113@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willy.

Unfortunately I can not work on this problem right now, but will do if
things are not resolved after Jan 11 (long vacations will be finished in
Russia and I will return to my test machines :) But right now I have
one quesstion: I read several times your mail but still can not figure
out if receiving or sending side is broken?

I.e. can you splice from socket into the file, check the file, and then
splice to the another socket and check received data to find out which
side is broken? Or did I just missed that in the problem description?

Thanks a lot for the test application, it will greatly help to resolve
this issue.

-- 
	Evgeniy Polyakov
