From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: multicast for v2.6.29
Date: Tue, 23 Jun 2009 17:41:19 +0300
Message-ID: <4A40E98F.5050903@iki.fi>
References: <4A40E151.10007@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:53181 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759055AbZFWOlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 10:41:18 -0400
Received: by ewy6 with SMTP id 6so174258ewy.37
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2009 07:41:20 -0700 (PDT)
In-Reply-To: <4A40E151.10007@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whoops. This was not supposed be sent on the list as-is.

This is more of an RFC, for what I want to do in future. Multicast routing
for NBMA destinations.

The patch is quick hack, and breaks ABI, and not intended for inclusion.
I suppose the multicast routing would need to be updated to Netlink era
before doing this kind of thing. And remove the hard coded limits such
as amount of MFC destinations and that you can have only one multicast
router user space process.

If you have any comments on the patch, they are appreciated.

Thanks,
  Timo

