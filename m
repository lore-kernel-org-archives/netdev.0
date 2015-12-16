From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next] ipv6: allow routes to be configured with
 expire values
Date: Wed, 16 Dec 2015 17:45:42 +0800
Message-ID: <CADvbK_emJxQ8E2P6YCdywCXOAApOObH2S-RBqTfpWDFAnTawVA@mail.gmail.com>
References: <20151211.202157.2045048466167764855.davem@davemloft.net>
	<CADvbK_fxww6-EfDgdo-4e=UscsB_pvJO4z1NAPiFyujiA5xr0Q@mail.gmail.com>
	<566EF98B.8060704@stressinduktion.org>
	<20151214.143645.1177969141058180151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	network dev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33444 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbbLPJpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 04:45:43 -0500
Received: by mail-ig0-f181.google.com with SMTP id mv3so126984261igc.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 01:45:43 -0800 (PST)
In-Reply-To: <20151214.143645.1177969141058180151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 3:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 14 Dec 2015 18:16:59 +0100
>
>> We can easily switch to new attributes. Should we introduce a new
>> interface for this?
>
> Yes.
okay, I will repost the patch with a new netlink attribute
