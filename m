From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: sctp: remove unused multiple cookie
 keys
Date: Tue, 12 Feb 2013 16:05:39 -0500 (EST)
Message-ID: <20130212.160539.954346046111294909.davem@davemloft.net>
References: <1360682133-17658-1-git-send-email-dborkman@redhat.com>
	<511A631A.60803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab3BLVFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:05:44 -0500
In-Reply-To: <511A631A.60803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 12 Feb 2013 10:43:22 -0500

> On 02/12/2013 10:15 AM, Daniel Borkmann wrote:
>> Vlad says: The whole multiple cookie keys code is completely unused
>> and has been all this time. Noone uses anything other then the
>> secret_key[0] since there is no changeover support anywhere.
>>
>> Thus, for now clean up its left-over fragments.
>>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Vlad Yasevich <vyasevic@redhat.com>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks everyone.
