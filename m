From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Tue, 18 Mar 2008 12:51:21 +0300
Message-ID: <47DF9099.30701@openvz.org>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com> <47DF7511.5080502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56846 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbYCRJvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 05:51:25 -0400
In-Reply-To: <47DF7511.5080502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

>> I can try either patch, but Patrick's looks simpler and thus perhaps
>> a better candidate this late in the -rc stage.
>>
>> Pavel - you concur?
> 
> No one, except for a complaint, ...

I wonder what I was thinking about when I wrote this :(

Phil, I agree with Patrick's patch.

