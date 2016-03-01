From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 0/9] mlx5 driver updates
Date: Tue, 1 Mar 2016 22:48:58 +0200
Message-ID: <CAJ3xEMiHJaHHh-GYV7tG0cLRFZ=TB0r-na3Htsqgw6H6D5ytHg@mail.gmail.com>
References: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
	<20160301.145134.1897442242357830301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>, Amir Vadai <amir@vadai.me>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34395 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcCAUs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:48:59 -0500
Received: by mail-io0-f173.google.com with SMTP id b188so19022307iof.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 12:48:58 -0800 (PST)
In-Reply-To: <20160301.145134.1897442242357830301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 9:51 PM, David Miller <davem@davemloft.net> wrote:
[...]
> I'm not going to allow two sets of parallel sets of changes to
> one driver you guys maintain to be submitted at once.
[...]
> Get one of these accepted first, then you can submit the other one.
> I'm tossing all of these changes, resubmit the one you want to be
> applied first.

Dave,

Point taken. I thought that since Amir's changes are dealing with
TC/flower offloads along with driver support, it's okay to submit that
in parallel for frequent driver updates that don't deal with core
networking stuff, and I was wrong :(

Saeed will re-submit his series and Amir's will wait for that one to
be accepted before he sends V1.

Or.
