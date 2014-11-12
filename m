From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] net: move vlan pop/push functions into
 common code
Date: Wed, 12 Nov 2014 14:11:15 -0500 (EST)
Message-ID: <20141112.141115.833376630768749357.davem@davemloft.net>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
	<CALnjE+qRASQx8pcaB7z9D3_x2ybA4h-Uh2Ppn9EJVG3YU8gSGg@mail.gmail.com>
	<20141112115933.GD1882@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbaKLTLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:11:19 -0500
In-Reply-To: <20141112115933.GD1882@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 12 Nov 2014 12:59:33 +0100

> That is not directly related to this patchset. I believe that should be
> changed in separate patch later on.

+1, but this has been a long standing issue and a large source of bugs.
