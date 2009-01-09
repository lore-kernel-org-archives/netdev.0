From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Fri, 9 Jan 2009 10:15:32 -0000 (WET)
Message-ID: <1216.192.168.1.3.1231496132.squirrel@webmail.decimal.pt>
References: <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
    <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
    <20090108110430.GB5493@ff.dom.local>
    <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
    <20090108135927.GC5493@ff.dom.local>
    <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt>
    <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
    <20090109075450.GC4605@ff.dom.local>
    <1071.192.168.1.3.1231494140.squirrel@webmail.decimal.pt>
    <20090109101214.GG4605@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly04.isp.novis.pt ([195.23.133.224]:58685 "EHLO
	mailrly04.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbZAIKPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:15:01 -0500
In-Reply-To: <20090109101214.GG4605@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Iproute is from distro, the kernel i compiled it by hand as always.
GCC 4.3.1 (could this interfer since it's very eary gcc version?)


> On Fri, Jan 09, 2009 at 09:42:20AM -0000, Jorge Bastos wrote:
>> Well, Debian using SID.
>> iproute (that's the last for SID):
>> ii  iproute                         20080725-2
>> networking
>> and traffic control tools
>>
>> lira:~# uname -a
>> Linux lira 2.6.28 #1 SMP Thu Dec 25 12:31:23 WET 2008 i686 GNU/Linux
>>
>> maybe i should ask the iproute package mainteiner to update it no?
>>
>
> Very strange. The versions look OK. Is it all distro's or
> recompiled? If the latter, could you try distro versions?
>
> Jarek P.
>


