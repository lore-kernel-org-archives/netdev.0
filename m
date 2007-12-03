From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: SSB: No is not an answer
Date: Mon, 3 Dec 2007 09:56:59 +0100
Message-ID: <20071203085659.GA2429@ff.dom.local>
References: <200712012127.50137.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"John W\. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43885 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751267AbXLCIwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 03:52:13 -0500
Content-Disposition: inline
In-Reply-To: <200712012127.50137.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-12-2007 21:27, Michael Buesch wrote:
> On Saturday 01 December 2007 20:00:23 Arnaldo Carvalho de Melo wrote:
>> Em Sat, Dec 01, 2007 at 12:45:32PM -0500, John W. Linville escreveu:
>>> On Sat, Dec 01, 2007 at 03:17:44PM -0200, Arnaldo Carvalho de Melo wrote:
>>>> Sonics Silicon Backplane support (SSB) [M/y/?] (NEW) n
>>>>
>>>> Support for the Sonics Silicon Backplane bus.
>>>> You only need to enable this option, if you are
>>>> configuring a kernel for an embedded system with
>>>> this bus.
>>>> It will be auto-selected if needed in other
>>>> environments.
>>>>
>>>> The module will be called ssb.
>>>>
>>>> If unsure, say N.
>>>>
>>>> Sonics Silicon Backplane support (SSB) [M/y/?] (NEW)
>>> I think this is OK -- it isn't really offering the choice to say
>>> no anyway.  You must have turned-on B44 or B43(LEGACY) already?
>>>
>>> So, your choice is merely whether to have it built-in or as a module.
>> Ok, so the comment on being unsure is wrong as we can't say N as
>> suggested :-)
> 
> Oh, come on... Read the _whole_ comment.

Why? IMHO "If unsure..." are kind of defaults just to let you not read
or understand "the whole comment". But here even reading the whole
doesn't make this less amusing, because it suggests you still have the
choice (eg. to revert auto-selection).

Regards,
Jarek P.
