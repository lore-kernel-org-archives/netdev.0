From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 21:51:13 +0100
Message-ID: <55147141.4080000@iogearbox.net>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us> <1427379836.29436.9.camel@stressinduktion.org> <20150326152938.GD2010@nanopsycho.orion> <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40676 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbbCZUvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 16:51:24 -0400
In-Reply-To: <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2015 09:39 PM, Hannes Frederic Sowa wrote:
...
> Albeit it looks a bit like cls_bpf could do that more easily.

I was also having this in mind. Jiri, do you see any shortcomings
that cls_bpf when eBPF'ed could currently not achieve (perhaps
we can improve that)?

Thanks,
Daniel
