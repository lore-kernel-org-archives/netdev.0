From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 09:12:54 -0700
Message-ID: <1379002374.24408.20.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	 <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47974 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab3ILQM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:12:56 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so8337pbb.20
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:12:56 -0700 (PDT)
In-Reply-To: <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 23:57 +0800, Hong Zhiguo wrote:
> not check IFF_BRIDGE_PORT within br_handle_frame
> 
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---

No need to hurry. Take the time to write an extensive changelog, and
test the patch !

Thanks
