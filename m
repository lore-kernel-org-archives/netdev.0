From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [take9 1/2] kevent: Core files.
Date: Wed, 16 Aug 2006 11:08:41 -0700
Message-ID: <44E35F29.8010500@oracle.com>
References: <11555364962921@2ka.mipt.ru> <1155536496588@2ka.mipt.ru> <20060816134550.GA12345@infradead.org> <20060816135642.GD4314@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55415 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1751242AbWHPSJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 14:09:28 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060816135642.GD4314@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>>> +	for (i=0; i<ARRAY_SIZE(u->kevent_list); ++i)
>> 	for (i = 0; i < ARRAY_SIZE(u->kevent_list); i++)
> 
> Ugh, no. It reduces readability due to exessive number of spaces.

Ihavetoverystronglydisagree.

- z
