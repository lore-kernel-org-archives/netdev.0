From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw implementation
Date: Tue, 1 Dec 2015 17:06:23 +0200
Message-ID: <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<20151201144300.GB2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, pjonnala@broadcom.com,
	j.vosburgh@gmail.com, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32935 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbLAPGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 10:06:24 -0500
Received: by iouu10 with SMTP id u10so12282902iou.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 07:06:24 -0800 (PST)
In-Reply-To: <20151201144300.GB2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 4:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>This patchset introduces needed infrastructure for link aggregation
>>offload - for both team and bonding. It also implements the offload
>>in mlxsw driver.

Hi Jiri,

I didn't see any changes to switchdev.h, can you elaborate on that please.

Or.
