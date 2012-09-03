From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: Possible issue with Mellanox mlx4/port handling
Date: Mon, 03 Sep 2012 15:16:53 -0300
Message-ID: <5044F415.4010605@redhat.com>
References: <953B660C027164448AE903364AC447D28720CF7D@MTLDAG01.mtl.com> <5044ECA9.5080100@redhat.com> <953B660C027164448AE903364AC447D28720CFEB@MTLDAG01.mtl.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398Ab2ICSQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 14:16:59 -0400
In-Reply-To: <953B660C027164448AE903364AC447D28720CFEB@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2012 02:51 PM, Yevgeny Petrilin wrote:
>> If you can share, what can we expect it to be like? Like the chunk I suggested
>> above or is there anything else needed? I could notice only 6 places calling
>> get_promisc_qp() that way and couldn't find any other issue like that.
>>
>
> The fix is pretty much the same style like what you suggested.

Awesome. Thanks!
Marcelo
