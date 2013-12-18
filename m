From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2 v2] qlcnic: make local functions static
Date: Wed, 18 Dec 2013 17:01:26 -0500 (EST)
Message-ID: <20131218.170126.2254636838925558157.davem@davemloft.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC1273B9F4A5@HQ1-EXCH02.corp.brocade.com>
	<20131218135438.71ea917f@nehalam.linuxnetplumber.net>
	<20131218135839.74010095@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab3LRWB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:01:28 -0500
In-Reply-To: <20131218135839.74010095@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 18 Dec 2013 13:58:39 -0800

> On Wed, 18 Dec 2013 13:54:38 -0800
> Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
>> Functions only used in one file should be static.
>> Found by running make namespacecheck
>> 
>> Compile tested only.
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> 
>> ---
>> v2 - update to latest net-next
> 
> Never mind, there is a duplicate declaration in here (won't compile).
> Let me re-send with full cleanup bundle.

OK.
