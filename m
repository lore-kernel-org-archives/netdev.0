From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/2] [iproute2] tc/q_htb.c: rename b4 buffer to b3 to
 make its name more consistent
Date: Fri, 18 Dec 2015 15:13:34 +0100
Message-ID: <20151218141334.GD19288@orbyte.nwl.cc>
References: <1450444599-29265-1-git-send-email-fw.dmitrii@yandex.com>
 <1450444599-29265-2-git-send-email-fw.dmitrii@yandex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	stephen@networkplumber.org
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36063 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932500AbbLRONf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 09:13:35 -0500
Content-Disposition: inline
In-Reply-To: <1450444599-29265-2-git-send-email-fw.dmitrii@yandex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 04:16:39PM +0300, Dmitrii Shcherbakov wrote:
> b3 buffer has been deleted previously so b2 is followed by b4 which is not consistent
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>

Acked-by: Phil Sutter <phil@nwl.cc>
