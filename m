From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Mon, 12 Jan 2009 09:49:16 -0000 (WET)
Message-ID: <2113.192.168.1.3.1231753756.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <200901082357.13396.denys@visp.net.lb>
    <20090109103030.GI4605@ff.dom.local>
    <200901091232.09923.denys@visp.net.lb>
    <20090109104411.GJ4605@ff.dom.local>
    <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt>
    <20090109105858.GA6098@ff.dom.local> <496AF0CE.7060406@trash.net>
    <20090112081342.GB4212@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly04.isp.novis.pt ([195.23.133.224]:48093 "EHLO
	mailrly04.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZALJtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 04:49:24 -0500
In-Reply-To: <20090112081342.GB4212@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Just wondering since this thread is very hard to follow with all
>> the top postings, incorrect timestamps on mails etc. - has there
>> been a resolution to this problem?
>>
>
> AFAIK, Jorge's CBQ+TBF problem was resolved with turning off TSO, but
> it looks like the resolution will be some warning added somewhere...
>
> Denys didn't yet confirm his HTB problem was resolved.
>
> Jarek P.
>

Reading this, this warnings must/will be added to TC correcto?

