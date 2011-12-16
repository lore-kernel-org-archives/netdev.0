From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: =?UTF-8?Q?nonlocal=5Fbind=20and=20IPv=36?=
Date: Fri, 16 Dec 2011 10:46:24 +0100
Message-ID: <8941b8bc9145cf466e557432665bf2fa@luffy.cx>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
 <4EEAE94A.5050400@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:35268 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295Ab1LPJq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 04:46:26 -0500
In-Reply-To: <4EEAE94A.5050400@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011 15:46:34 +0900, YOSHIFUJI Hideaki wrote:
> Have you tried to send packets from the application on node with
> local_bind enabled (without the address the application binds)?

No, I did not see any logic to handle this with IPv4. I will test it 
and come back.
