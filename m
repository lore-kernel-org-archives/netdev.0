From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net_sched: htb: fix a typo in htb_change_class()
Date: Wed, 11 Sep 2013 07:58:27 +0200
Message-ID: <20130911055827.GB1404@minipsycho.orion>
References: <1378859797.26319.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Vimalkumar <j.vimal@gmail.com>, Jiri Pirko <jpirko@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:46086 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab3IKF6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 01:58:31 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so4366615eek.16
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 22:58:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1378859797.26319.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 11, 2013 at 02:36:37AM CEST, eric.dumazet@gmail.com wrote:
>From: Vimalkumar <j.vimal@gmail.com>
>
>Fix a typo added in commit 56b765b79 ("htb: improved accuracy at high
>rates")
>
>cbuffer should not be a copy of buffer.
>
>Signed-off-by: Vimalkumar <j.vimal@gmail.com>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>Cc: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
