From: mihail.dakov@ng4t.com
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 20:32:53 +0200
Message-ID: <20140721203253.Horde.9bpg4-qQqIsddySIO6hXOw1@ssl.lux01.de>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com>
 <53CD2661.8070707@ng4t.com> <53CD2E08.7070204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud15.udmedia.de ([194.117.254.55]:56666 "EHLO
	mail.ud15.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933219AbaGUSc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:32:59 -0400
In-Reply-To: <53CD2E08.7070204@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting Daniel Borkmann <dborkman@redhat.com>:

> On 07/21/2014 04:40 PM, Mihail Dakov wrote:
> ...
>> What'd you mean by local traffic? The packets which are replicated  
>> are destined to remote machine(s).
>
> Sure, but you are sending them out via your packet socket.

Well yes. It's just that I interpreted local as if they were not going  
out of the machine. But in fact they do.
