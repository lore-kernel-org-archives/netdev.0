From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Mon, 12 Jan 2009 08:13:42 +0000
Message-ID: <20090112081342.GB4212@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082357.13396.denys@visp.net.lb> <20090109103030.GI4605@ff.dom.local> <200901091232.09923.denys@visp.net.lb> <20090109104411.GJ4605@ff.dom.local> <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt> <20090109105858.GA6098@ff.dom.local> <496AF0CE.7060406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jorge Bastos <mysql.jorge@decimal.pt>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:56782 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbZALINr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 03:13:47 -0500
Received: by mail-ew0-f17.google.com with SMTP id 10so11359794ewy.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 00:13:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496AF0CE.7060406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 08:27:10AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Fri, Jan 09, 2009 at 10:47:11AM -0000, Jorge Bastos wrote:
>>> For my case this has any matter?
>>>
>>
>> I guess not: it's about better resolution, so e.g. when 2% matters.
>> And it matters for a desktop box, if you care about responsiveness.
>
> Just wondering since this thread is very hard to follow with all
> the top postings, incorrect timestamps on mails etc. - has there
> been a resolution to this problem?
>

AFAIK, Jorge's CBQ+TBF problem was resolved with turning off TSO, but
it looks like the resolution will be some warning added somewhere...

Denys didn't yet confirm his HTB problem was resolved.

Jarek P.
