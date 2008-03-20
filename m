From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Thu, 20 Mar 2008 16:33:45 +0100
Message-ID: <47E283D9.9080801@trash.net>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com> <47DF7511.5080502@openvz.org> <47DF9099.30701@openvz.org> <20080320003917.GA9198@linuxace.com> <47E2790A.9040206@trash.net> <20080320153017.GA2106@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:11641 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420AbYCTPdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 11:33:54 -0400
In-Reply-To: <20080320153017.GA2106@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester wrote:
> On Thu, Mar 20, 2008 at 03:47:38PM +0100, Patrick McHardy wrote:
>>> And it has survived 1.5 days without issue.  Patrick - will you be pushing
>>> to David?
>> Could you send the patch you've been using?
> 
> Sure - attached below against current git.  I assume you will add your
> signoff, but you can add
> 
> Tested-by: Phil Oester <kernel@linuxace.com>

Thanks,

Acked-by: Patrick McHardy <kaber@trash.net>
