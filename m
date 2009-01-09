From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 10:12:14 +0000
Message-ID: <20090109101214.GG4605@ff.dom.local>
References: <20090108095403.GE4496@ff.dom.local> <20090108100614.GA5418@ff.dom.local> <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt> <20090108110430.GB5493@ff.dom.local> <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt> <20090108135927.GC5493@ff.dom.local> <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt> <20090109075450.GC4605@ff.dom.local> <1071.192.168.1.3.1231494140.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jorge Bastos <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26528 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780AbZAIKMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:12:21 -0500
Received: by ey-out-2122.google.com with SMTP id 22so1110041eye.37
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 02:12:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1071.192.168.1.3.1231494140.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 09:42:20AM -0000, Jorge Bastos wrote:
> Well, Debian using SID.
> iproute (that's the last for SID):
> ii  iproute                         20080725-2                 networking
> and traffic control tools
> 
> lira:~# uname -a
> Linux lira 2.6.28 #1 SMP Thu Dec 25 12:31:23 WET 2008 i686 GNU/Linux
> 
> maybe i should ask the iproute package mainteiner to update it no?
> 

Very strange. The versions look OK. Is it all distro's or
recompiled? If the latter, could you try distro versions?

Jarek P.
