From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 -next] ip: route: add congestion control setting
Date: Thu, 11 Dec 2014 00:46:52 +0100
Message-ID: <5488DB6C.7090609@redhat.com>
References: <1417793298-6439-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758268AbaLJXrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 18:47:04 -0500
In-Reply-To: <1417793298-6439-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2014 04:28 PM, Daniel Borkmann wrote:
> This patch adds configuration and dumping of congestion control metric
> for ip route, f.e.:  ip route add <dst> dev <dev> congctl [lock] <name>
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Stephen, you can drop this one; net-next just got closed and for
the module auto-loading which is almost ready, I will send a v2
for iproute2 as some man-page bits needs changes here.

But all that when net-next opens up again.

Thanks,
Daniel
