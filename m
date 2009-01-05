From: "Frank Groeneveld" <frankgroeneveld@gmail.com>
Subject: Re: Kernel 2.6.28 regression: Hang after hibernate (patch included)
Date: Mon, 5 Jan 2009 17:49:55 +0100
Message-ID: <a00b9da20901050849k512512cfg120e97beef3edaae@mail.gmail.com>
References: <a00b9da20812281234u76da2ef5tb715f4c409eaf37c@mail.gmail.com>
	 <a00b9da20901020910i2625073av96ce68ec0c313a8c@mail.gmail.com>
	 <a00b9da20901021118h3e698d04q33fa9e87519e4d42@mail.gmail.com>
	 <200901022318.45675.rjw@sisk.pl>
	 <20090104192502.GA6196@electric-eye.fr.zoreil.com>
	 <a00b9da20901041244h7a2146a3l93df6c9935613cae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, "Pavel Machek" <pavel@suse.cz>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:65447 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbZAEQt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 11:49:57 -0500
In-Reply-To: <a00b9da20901041244h7a2146a3l93df6c9935613cae@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/1/4 Frank Groeneveld <frankgroeneveld@gmail.com>:
> 2009/1/4 Francois Romieu <romieu@fr.zoreil.com>:
>> [...]
>>
>> Frank, can you:
>> 1. try the r8169.c file from the 2.6.28 tree with Ubuntu's kernel

This results in a fine working system. Resume and hibernate work just
the way they should.

Frank
