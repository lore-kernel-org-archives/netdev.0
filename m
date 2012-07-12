From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 0/3] team: couple of patches
Date: Thu, 12 Jul 2012 17:53:36 +0200
Message-ID: <20120712155336.GA1719@minipsycho.orion>
References: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
 <20120712.081124.1207448876900334978.davem@davemloft.net>
 <20120712.081443.1373285885474644661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755142Ab2GLPxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 11:53:39 -0400
Content-Disposition: inline
In-Reply-To: <20120712.081443.1373285885474644661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 12, 2012 at 05:14:43PM CEST, davem@davemloft.net wrote:
>From: David Miller <davem@davemloft.net>
>Date: Thu, 12 Jul 2012 08:11:24 -0700 (PDT)
>
>> From: Jiri Pirko <jpirko@redhat.com>
>> Date: Wed, 11 Jul 2012 17:34:01 +0200
>> 
>>> Jiri Pirko (3):
>>>   team: use function team_port_txable() for determing enabled and up
>>>     port
>>>   team: add broadcast mode
>>>   team: make team_port_enabled() and team_port_txable() static inline
>> 
>> All applied, thanks.
>
>Jiri, btw, any chance I can convince you to remove the EXPERIMENTAL
>Kconfig dependency?
>
>Code I've written and checked in myself over the past few days is
>several orders of magnitude more experimental than the team driver
>is :-)

Hehe :) Nevertheless, I would like to keep this flag for some more time.
I will remove that once I have all planned basic functionality in.

Jirka
