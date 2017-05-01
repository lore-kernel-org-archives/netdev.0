From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip xfrm: Add xfrm state crypto
 offload
Date: Mon, 1 May 2017 09:31:21 -0700
Message-ID: <20170501093121.5ace5e54@xeon-e3>
References: <20170430141602.30995-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>, Boris Pismenny <borisp@mellanox.com>
To: <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34866 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762566AbdEAQbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:31:24 -0400
Received: by mail-pg0-f54.google.com with SMTP id o3so41786023pgn.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:31:24 -0700 (PDT)
In-Reply-To: <20170430141602.30995-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Apr 2017 17:16:02 +0300
<ilant@mellanox.com> wrote:

> From: Boris Pismenny <borisp@mellanox.com>
> 
> syntax:
> ip xfrm state .... offload dev <if-name> dir <in or out>
> 
> Example to add inbound offload:
>   ip xfrm state .... offload dev mlx0 dir in
> Example to add outbound offload:
>   ip xfrm state .... offload dev mlx0 dir out
> 
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>


Applied to net-next
