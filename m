From: Ben Greear <greearb@candelatech.com>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 22:53:40 -0800
Message-ID: <49ACD3F4.8080700@candelatech.com>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <49AC545E.3090708@trash.net> <20090302223011.GA3388@ami.dom.local> <49AC6D24.1030605@trash.net> <20090303064149.GA4154@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39868 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbZCCGxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:53:51 -0500
In-Reply-To: <20090303064149.GA4154@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Yes, very interesting arguments for another disussion... But if we're
> talking about naming than you seem to ignore what Lennart, Ben, Denys
> and probably Stephen said about their preferred way, and I think it
> matters, because if they had problems with understanding this change
> I can only imagine what "common users" would say without knowing all
> this technical rationale (which IMHO is disputable too - names  are
> for people).
>   
I like my own naming scheme, and I use it by specifying the name when
creating the vlan using 'ip'.  It would have been nice (IMO) to have the
dev.vid naming be default from the beginning, but since it wasn't, it would
cause more harm than good to change it now.

So, I'm NOT arguing for changing the behaviour, though anything that can
document the features of 'ip' better and make it more obvious you can set
the name upon creation should help people...

Ben

> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


