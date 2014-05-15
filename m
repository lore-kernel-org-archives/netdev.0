From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: bonding directly changes underlying device address
Date: Thu, 15 May 2014 06:55:25 +0200
Message-ID: <20140515045524.GA27773@mikrodark.usersys.redhat.com>
References: <5371FCD0.7050502@mellanox.com>
 <20140513115527.GC2910@minipsycho.orion>
 <20030.1399998641@localhost.localdomain>
 <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com>
 <20140514080114.GA30960@mikrodark.usersys.redhat.com>
 <5046.1400117925@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:55298 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbaEOEzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 00:55:47 -0400
Received: by mail-we0-f176.google.com with SMTP id q59so485411wes.7
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 21:55:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5046.1400117925@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 06:38:45PM -0700, Jay Vosburgh wrote:
...snip...
>	So, I'd say "No" to conversion to dev_set_mac_address() and
>"show me the code" to the "stash it in the slave" plan.

Ok, got it, I will try to move it to struct slave.

Thank you!

>
>	-J
>
>---
>	-Jay Vosburgh, jay.vosburgh@canonical.com
