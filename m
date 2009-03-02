From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 21:07:03 +0100
Message-ID: <49AC3C67.9040809@gmail.com>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <20090302193604.GI23244@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:60830 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbZCBUIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 15:08:41 -0500
Received: by bwz26 with SMTP id 26so2085813bwz.37
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2009 12:08:38 -0800 (PST)
In-Reply-To: <20090302193604.GI23244@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennart Sorensen wrote, On 03/02/2009 08:36 PM:

> On Mon, Mar 02, 2009 at 07:51:08PM +0100, Jarek Poplawski wrote:
>> Even if you have only one ethX?
> 
> Yes.  What vlan number is vlan0 talking to on ethX?
> 
> Not that eth0 ever told you much useful, but at least eth0.0005 told
> you something. [...]


OK, you're right! More info is better. ...How about changing this
silly "eth" thing to something really useful like BSDs do?!

Jarek P.

