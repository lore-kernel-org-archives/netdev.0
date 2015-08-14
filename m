From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH RFC net 0/3] ipv6: Fix potential deadlock when creating
 pcpu rt
Date: Fri, 14 Aug 2015 12:13:47 +0200
Message-ID: <20150814101347.GA31630@sesse.net>
References: <20150808100028.GA14897@sesse.net>
 <1439452683-964514-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	FB Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:42848 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbbHNKNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 06:13:52 -0400
Content-Disposition: inline
In-Reply-To: <1439452683-964514-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 12:58:00AM -0700, Martin KaFai Lau wrote:
> Steinar, the patches can also be applied to 4.2-rc5 (I just tried).
> Can you help to test them? Thanks!

I won't be doing a boot in the near future (I want my server to be up,
sorry :-) ), but if I _do_ have to boot, I'll be sure to apply your patches
on top of 4.2-whatever-is-newest-at-the-time.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
