From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 23:30:11 +0100
Message-ID: <20090302223011.GA3388@ami.dom.local>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <49AC545E.3090708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:46398 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbZCBWal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:30:41 -0500
Received: by bwz26 with SMTP id 26so2142511bwz.37
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2009 14:30:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49AC545E.3090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 10:49:18PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Lennart Sorensen wrote, On 03/02/2009 06:20 PM:
>>
>>> On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
>>>> Why is interface created through netlink named 'vlan0' and
>>>> interface created through old vconfig called 'ethX.YY'.
>>>> Seems like the interface should be consistent.
>>> That does seem silly.
>>>
>>> ethX.YYYY told you which physical interface and which vlan number it was.
>>>
>>> vlan0 tells you nothing useful.
>>  
>>
>> Even if you have only one ethX?
>
> The binding is displayed when listing interfaces. This hole
> argument is silly, if you want a particular name, just specify
> it. The current naming schemes are entirely based on information
> that you have to specify anyways.

Just for the record, I don't agree with calling "this" argument silly
just like it was with "that" argument. Actually, I think they are
both so "right" that I've changed my mind and think it's great each
tool does it differently...

Jarek P.
