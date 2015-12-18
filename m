From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/2] [iproute2] tc/q_htb.c: remove printing of a
 deprecated overhead value previously encoded as a part of mpu field
Date: Fri, 18 Dec 2015 15:26:08 +0100
Message-ID: <20151218152608.3f08159d@redhat.com>
References: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, stephen@networkplumber.org,
	brouer@redhat.com
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753577AbbLRO0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 09:26:13 -0500
In-Reply-To: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 18 Dec 2015 16:16:38 +0300 Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:

> Remove printing according to the previously used encoding of mpu and overhead values within the tc_ratespec's mpu field. This encoding is no longer being used as a separate 'overhead' field in the ratespec structure has been introduced.
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> ---

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Thank you Dmitrii for cleaning this up :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
