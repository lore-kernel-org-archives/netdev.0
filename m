From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH] smc91x: SMC_IO_SHIFT platform data support for default case
Date: Wed, 10 Sep 2008 16:44:14 +0900
Message-ID: <aec7e5c30809100044g1a51e7bfj240bdd67c5cb3012@mail.gmail.com>
References: <20080908050234.11554.10123.sendpatchset@rx1.opensource.se>
	 <20080908111922.GA15553@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.miao@marvell.com,
	luca.santini@spesonline.com, nico@cam.org, linux-sh@vger.kernel.org
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:51678 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYIJHoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 03:44:15 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2277395rvb.1
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 00:44:14 -0700 (PDT)
In-Reply-To: <20080908111922.GA15553@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon!

On Mon, Sep 8, 2008 at 8:19 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 08, 2008 at 02:02:34PM +0900, Magnus Damm wrote:
>> From: Magnus Damm <damm@igel.co.jp>
>>
>> Commit 159198862adad7109bb347bb30a620f67beac45f added SMC_IO_SHIFT
>> platform data support. After that ARM board support was added.
>>
>> The default case is still missing though, so on SuperH SMC_IO_SHIFT
>> is constantly zero regardless of what you pass as platform data.
>
> I beleive that its now common practice to include the subject
> of a commit along with its id, as the latter can change as
> it moves from tree to tree.

Oh, thanks for pointing that out. I should really do that next time.

In this case the commit id is from the linux-2.6 git, so shouldn't it
be stable enough? Isn't it the final destination? =)

Thanks!

/ magnus
