From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: Re: [Bridge] notifier chain on br0
Date: Thu, 3 Dec 2009 15:17:30 +0530
Message-ID: <cfeab66d0912030147y5b3b9245x159c96c368db9090@mail.gmail.com>
References: <cfeab66d0912010626n43e2a971gdc8a23b976256c56@mail.gmail.com>
	 <20091201083202.719890c6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:45040 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862AbZLCJrY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 04:47:24 -0500
Received: by iwn1 with SMTP id 1so778761iwn.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 01:47:30 -0800 (PST)
In-Reply-To: <20091201083202.719890c6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a ton.

Ratheesh

On Tue, Dec 1, 2009 at 10:02 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Tue, 1 Dec 2009 19:56:03 +0530
> ratheesh k <ratheesh.ksz@gmail.com> wrote:
>
>> Hi All ,
>>
>> =A0i =A0have a software bridge br0 on eth0 and eth1 . Can i use NETL=
INK
>> sockets to get ip address change notification on br0 .???
>>
>> Thanks,
>> Ratheesh
>
> Netlink reports all interfaces including br0
>
