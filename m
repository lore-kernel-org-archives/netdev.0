From: "=?ISO-8859-1?Q?Jan-Aage_Frydenb=F8-Bruvoll?="
	<jan@frydenbo-bruvoll.com>
Subject: Re: bad htb_{en,re}queue return codes causing corrupt data in drivers
Date: Thu, 8 Jan 2009 16:12:27 +0000
Message-ID: <a70c39fa0901080812l62c0a88ewa06954931fbefb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:51724 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757867AbZAHQMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 11:12:33 -0500
Received: by yw-out-2324.google.com with SMTP id 9so2853519ywe.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 08:12:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It hasn't, we're doing an audit of the entire packet scheduler layer
> to make sure we fix this bug everywhere it occurs.
>
> Thanks for pinging us.

Hi,

As I've just installed 2.6.28 (vanilla) and seen the same type of
crash that has been bugging me for the last couple of weeks, I was
just wondering how I can get at this fix for my boxes, or when the fix
could be expected to enter the mainstream tree?

Thanks
Jan
