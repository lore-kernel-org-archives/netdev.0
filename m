From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Re: A question about hh_cache
Date: Sun, 30 Dec 2007 17:12:05 +0200
Message-ID: <147a89290712300712p5c586f57wff1b29e9fa807dee@mail.gmail.com>
References: <147a89290712300531m4a8845betd23ef71f6d944799@mail.gmail.com>
	 <p73abns1be1.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:34703 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbXL3PMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 10:12:07 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2420942fga.17
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2007 07:12:05 -0800 (PST)
In-Reply-To: <p73abns1be1.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
First, thanks for your reply.

Second, apart from when using both IPV4 and IPV6:
Suppose I work only in IPv4 (and this is indeed the case).

Can there be a case in such environment (using IPv4 only) where
hh_cache of a neighbour instance is a
list with more than one entry ?

Regards,
Andy Johnson



On Dec 30, 2007 4:54 PM, Andi Kleen <andi@firstfloor.org> wrote:
> "Andy Johnson" <johnsonzjo@gmail.com> writes:
>
> > Can anybody give an example when hh_cache of a neighbour instance is a
> > list with more than
> > one entry ?
>
> When you're talking to the same host on a local ethernet with both native IPv4
> and native IPv6.
>
> -Andi
>
