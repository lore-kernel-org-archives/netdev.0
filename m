From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 19:51:08 +0100
Message-ID: <49AC2A9C.5090303@gmail.com>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:57007 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbZCBSwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 13:52:18 -0500
Received: by fxm24 with SMTP id 24so2114076fxm.37
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2009 10:52:15 -0800 (PST)
In-Reply-To: <20090302172057.GA23247@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennart Sorensen wrote, On 03/02/2009 06:20 PM:

> On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
>> Why is interface created through netlink named 'vlan0' and
>> interface created through old vconfig called 'ethX.YY'.
>> Seems like the interface should be consistent.
> 
> That does seem silly.
> 
> ethX.YYYY told you which physical interface and which vlan number it was.
> 
> vlan0 tells you nothing useful.
 

Even if you have only one ethX?

Jarek P.
