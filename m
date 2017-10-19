From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] spectrum: Convert fib event handlers to use
 container_of on info arg
Date: Thu, 19 Oct 2017 09:09:01 +0200
Message-ID: <20171019070901.GA1978@nanopsycho.orion>
References: <1508364098-29621-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:56321 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdJSHJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 03:09:04 -0400
Received: by mail-wm0-f49.google.com with SMTP id l68so14225857wmd.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 00:09:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508364098-29621-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 12:01:38AM CEST, dsahern@gmail.com wrote:
>Use container_of to convert the generic fib_notifier_info into
>the event specific data structure.
>
>Signed-off-by: David Ahern <dsahern@gmail.com>
>Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
