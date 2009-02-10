From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] cassini: i reaches 0, not -1.
Date: Tue, 10 Feb 2009 10:18:04 +0100
Message-ID: <4991464C.2050500@gmail.com>
References: <4990AA32.1010004@gmail.com> <20090209.175600.191087624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:34341 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbZBJJSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 04:18:08 -0500
In-Reply-To: <20090209.175600.191087624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Mon, 09 Feb 2009 23:12:02 +0100
> 
>> With while (i-- > 0) { ... } i reaches 0, not -1.
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Does it?

No, you're right, sorry, please ignore :-/
