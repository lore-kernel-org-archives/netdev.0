From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/42] mlxsw: Implement IPV4 unicast routing
Date: Sat, 2 Jul 2016 08:31:17 +0200
Message-ID: <20160702063117.GB1995@nanopsycho.orion>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <20160701.152716.1930131608670556376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37044 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcGBGbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 02:31:20 -0400
Received: by mail-wm0-f42.google.com with SMTP id a66so53157702wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 23:31:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160701.152716.1930131608670556376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 01, 2016 at 09:27:16PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri,  1 Jul 2016 16:04:28 +0200
>
>> This patchset enables IPv4 unicast routing in the Mellanox Spectrum
>> ASIC switch driver. The basic dependencies are already present in
>> the kernel and used by rocker.
>
>Please split this up into smaller segments (~15 patches, max) and
>resubmit.
>
>A 42 patch series present an unreasonable burdon for reviewers.

Yeah, I did not want to cut it as it is one logical subject.

Will cut it. Thanks.
