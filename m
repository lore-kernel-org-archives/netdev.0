From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] [iproute2] tc/q_htb.c: rename b4 buffer to b3 to
 make its name more consistent
Date: Fri, 18 Dec 2015 15:26:44 +0100
Message-ID: <20151218152644.3b00987e@redhat.com>
References: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
	<1450444599-29265-2-git-send-email-fw.dmitrii@yandex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, stephen@networkplumber.org,
	brouer@redhat.com
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933150AbbLRO0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 09:26:48 -0500
In-Reply-To: <1450444599-29265-2-git-send-email-fw.dmitrii@yandex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2015 16:16:39 +0300
Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:

> b3 buffer has been deleted previously so b2 is followed by b4 which is not consistent
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> ---

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
