From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 1/3] ip: add support of netconf messages
Date: Wed, 12 Dec 2012 18:03:37 +0100
Message-ID: <50C8B8E9.4080402@6wind.com>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com> <20121212085959.31d8cd79@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55846 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab2LLRDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:03:40 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so632064eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 09:03:39 -0800 (PST)
In-Reply-To: <20121212085959.31d8cd79@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2012 17:59, Stephen Hemminger a =E9crit :
> Ok, but the headers for all of iproute2 are supposed to come from
> sanitized kernel headers from "make headers_install"
>
> You missed that piece in the original patch.
>
Right! I will update the patch.
