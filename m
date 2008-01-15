From: Patrick McHardy <kaber@trash.net>
Subject: Re: Not understand some in htb_do_events function
Date: Tue, 15 Jan 2008 11:15:53 +0100
Message-ID: <478C87D9.1010305@trash.net>
References: <478C86E6.3050508@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34740 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbYAOKQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 05:16:04 -0500
In-Reply-To: <478C86E6.3050508@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote:
> Hello all.
> I have many messages like "htb: too many events !" in dmesg.
> 
> Try to see code and find that function try do 500 events at call.
> Hm... may anyone ask why 500? Why its not dynamic value based on 
> performance of PC?


Thats a good question, I wonder why it is limited at all.
Martin, any hints?


