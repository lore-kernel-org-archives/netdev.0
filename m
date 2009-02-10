From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] netdevice: ticks reaches 25, not 26.
Date: Tue, 10 Feb 2009 10:19:04 +0100
Message-ID: <49914688.3090509@gmail.com>
References: <4990AC93.3080906@gmail.com> <20090209.175714.70463534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:9354 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZBJJTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 04:19:09 -0500
In-Reply-To: <20090209.175714.70463534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Mon, 09 Feb 2009 23:22:11 +0100
> 
>> With while (tick++ < 25) { ... } ticks reaches 25, not 26.
> 
> Does it?

Again, you're right, sorry, please ignore :-/
