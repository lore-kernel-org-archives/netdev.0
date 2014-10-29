From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: some failures with vxlan offloads..
Date: Wed, 29 Oct 2014 17:56:02 +0200
Message-ID: <54510E12.1030903@mellanox.com>
References: <544CF8E3.8070207@mellanox.com>	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>	<CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>	<CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>	<544FB5CA.2060003@mellanox.com>	<CA+mtBx_ncYrp_fbp8ucXfBaCoPpv_X+TEsmofCnpzTyPPfLXnw@mail.gmail.com>	<54508020.1040305@mellanox.com> <CA+mtBx9TCtHgW=TegUgjZ6Se=mP+0CNiNHYmbYHPd1cJJGYoBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:33388 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932994AbaJ2P4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 11:56:07 -0400
In-Reply-To: <CA+mtBx9TCtHgW=TegUgjZ6Se=mP+0CNiNHYmbYHPd1cJJGYoBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2014 4:59 PM, Tom Herbert wrote:
>> >OK, I'll look there. Anything that should worries us at that stack trace I
>> >sent in my initial email of this thread, or you think this is related to the
>> >mlx4 driver checksum bug?
>> >
> The trace doesn't seem like it would be related to a checksum bug. Do you only see this with offload enabled?

no, it happened on the server side of configuration #4 in my original 
email, which is offloaded client and non-offloaded server.

Or.
