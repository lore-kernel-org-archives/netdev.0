From: David Lang <dlang@digitalinsight.com>
Subject: Re: Updated sysctl documentation take #2
Date: Wed, 7 Jun 2006 15:52:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.63.0606071551310.2093@qynat.qvtvafvgr.pbz>
References: <20060607205316.bbb3c379.diegocg@gmail.com> <20060607235631.GA10688@linuxtv.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Diego Calleja <diegocg@gmail.com>, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org, linux-xfs@oss.sgi.com,
	ecki@lina.inka.de, lkml@rtr.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from warden-p.diginsite.com ([208.29.163.248]:50106 "HELO
	warden.diginsite.com") by vger.kernel.org with SMTP id S932519AbWFHBEH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 21:04:07 -0400
To: Johannes Stezenbach <js@linuxtv.org>
In-Reply-To: <20060607235631.GA10688@linuxtv.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Jun 2006, Johannes Stezenbach wrote:

> On Wed, Jun 07, 2006, Diego Calleja wrote:
>> Since people didn't like the "many small files" approach, I've moved
>> it to directories containing index.txt files:
>>
>> Documentation/sysctl/vm/index.txt
>> Documentation/sysctl/net/core/index.txt
>
> Why not just
>
> Documentation/sysctl/vm.txt
> Documentation/sysctl/net/core.txt
>
> etc.?

better matching of the proc layout would be my guess.
