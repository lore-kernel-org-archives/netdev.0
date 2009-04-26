From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Sun, 26 Apr 2009 16:27:32 +0200
Message-ID: <49F46F54.2060309@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>	<49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <49F462A8.5060008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43865 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbZDZO2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 10:28:36 -0400
In-Reply-To: <49F462A8.5060008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> Eric Dumazet wrote, On 04/26/2009 12:46 PM:
>=20
> ...
>> [PATCH] poll: Avoid extra wakeups in select/pol
>=20
> ...
>=20
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>>  fs/select.c          |   28 +++++++++++++++++++++++++---
>>  include/linux/poll.h |    3 +++
>>  2 files changed, 28 insertions(+), 3 deletions(-)
>=20
>=20
> Eric, I wonder why you've forgotten about linux-kernel@ folks...
>=20

Ah yes, I forgot, I only did a 'reply all' on David's mail.
I'll resubmit it anyway, since it was only a followup.

