From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v5 2/2] pktgen: introduce xmit_mode '<start_xmit|netif_receive>'
Date: Thu, 07 May 2015 19:20:09 +0200
Message-ID: <554B9EC9.9060407@iogearbox.net>
References: <20150507143329.8534.49710.stgit@ivy> <20150507143500.8534.4435.stgit@ivy> <554B9293.2070702@plumgrid.com> <554B9CDE.1050703@iogearbox.net> <554B9DF9.4070909@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55393 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbEGRUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:20:14 -0400
In-Reply-To: <554B9DF9.4070909@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2015 07:16 PM, Alexei Starovoitov wrote:
> On 5/7/15 10:11 AM, Daniel Borkmann wrote:
>>
>> You mean other than below commit (iow independant of queue mapping)?
>>
>> commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b
>> Author: Robert Olsson <robert.olsson@its.uu.se>
>> Date:   Thu Aug 7 02:23:01 2008 -0700
>>
>>      pktgen: multiqueue etc.
>
> ahh, I felt that I'm missing something ;)
> Too bad it's not documented. I couldn't figure that out from sources.
> Thanks! will give it a shot.

Ok, in any case, I think it would be good if there's some
documentation for that as well. :)
