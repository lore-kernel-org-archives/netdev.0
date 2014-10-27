From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3] ipv6: notify userspace when we added or changed an
 ipv6 token
Date: Mon, 27 Oct 2014 23:25:38 +0100
Message-ID: <544EC662.4060607@redhat.com>
References: <544D8234.5060504@redhat.com> <1414427956-20056-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbaJ0WZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 18:25:49 -0400
In-Reply-To: <1414427956-20056-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2014 05:39 PM, Lubomir Rintel wrote:
> NetworkManager might want to know that it changed when the router advertisement
> arrives.
>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Daniel Borkmann <dborkman@redhat.com>

Looks better, thanks!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
