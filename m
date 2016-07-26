From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] virtio: use kcalloc and kmalloc_array
Date: Tue, 26 Jul 2016 11:05:25 -0700 (PDT)
Message-ID: <20160726.110525.1182013729015082606.davem@davemloft.net>
References: <20160726162008.310530368@networkplumber.org>
	<20160726162037.897138759@networkplumber.org>
	<20160726093543.1525924e@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbcGZSF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 14:05:29 -0400
In-Reply-To: <20160726093543.1525924e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 26 Jul 2016 09:35:43 -0700

> On Tue, 26 Jul 2016 09:20:11 -0700
> Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
>> Preferred style is to use kcalloc and kmalloc_array.
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Do not apply, needs redo. Wasn't updated. properl

net-next is closed anyways, please resubmit this series after the
merge window.
