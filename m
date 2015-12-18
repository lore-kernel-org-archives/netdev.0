From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 1/2] [iproute2] tc/q_htb.c: remove printing of a
 deprecated overhead value previously encoded as a part of mpu field
Date: Fri, 18 Dec 2015 15:13:19 +0100
Message-ID: <20151218141319.GC19288@orbyte.nwl.cc>
References: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	stephen@networkplumber.org
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37114 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297AbbLRONV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 09:13:21 -0500
Content-Disposition: inline
In-Reply-To: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 04:16:38PM +0300, Dmitrii Shcherbakov wrote:
> Remove printing according to the previously used encoding of mpu and overhead values within the tc_ratespec's mpu field. This encoding is no longer being used as a separate 'overhead' field in the ratespec structure has been introduced.
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>

Acked-by: Phil Sutter <phil@nwl.cc>
