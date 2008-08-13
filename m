From: "David Madsen" <david.madsen@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Tue, 12 Aug 2008 17:39:20 -0700
Message-ID: <ec7e30370808121739o6b07393bp986dfb85344b30a8@mail.gmail.com>
References: <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
	 <20080805214250.GA23226@electric-eye.fr.zoreil.com>
	 <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
	 <20080806190353.GB17174@electric-eye.fr.zoreil.com>
	 <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
	 <20080807223137.GA17407@electric-eye.fr.zoreil.com>
	 <2c2a4e250808072028h8b7a13av29ec02f76ab08cd1@mail.gmail.com>
	 <2c2a4e250808072051v6b0b42eaxb66e927e094dba78@mail.gmail.com>
	 <ec7e30370808112242y4be0ba5fy6d3567e0dc49b6fd@mail.gmail.com>
	 <20080812201847.GA1582@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:65094 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbYHMAjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 20:39:22 -0400
Received: by mu-out-0910.google.com with SMTP id w8so4722851mue.1
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 17:39:20 -0700 (PDT)
In-Reply-To: <20080812201847.GA1582@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Please note that the kernel complains more loudly about the watchdog
> than it used to. Does it allow traffic to flow afterwards ?
>

Likewise for me, the connection does come back up and continues to
function.  Prior to the upgrade and switch to MSI though I never had
any glitches like these that are occurring now.  Hopefully I'll be
able to disable MSI sometime this week to test out that theory.  Since
these timeouts are not easily forced (seems to be unaffected by
traffic load) It may take a while to confirm whether that fixes the
problem or not.

--David Madsen
