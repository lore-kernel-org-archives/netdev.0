From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC] Allow to turn off TCP window scale opt per route
Date: Wed, 21 Oct 2009 10:40:24 +0900
Message-ID: <20091021104024.32adab23@s6510>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
	<1256052161-14156-2-git-send-email-gilad@codefidence.com>
	<1256052161-14156-3-git-send-email-gilad@codefidence.com>
	<1256052161-14156-4-git-send-email-gilad@codefidence.com>
	<1256052161-14156-5-git-send-email-gilad@codefidence.com>
	<1256052161-14156-6-git-send-email-gilad@codefidence.com>
	<1256052161-14156-7-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com,
	Gilad Ben-Yossef <gilad@codefidence.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50330 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbZJUBk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2009 21:40:28 -0400
In-Reply-To: <1256052161-14156-7-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2009 17:22:39 +0200
Gilad Ben-Yossef <gilad@codefidence.com> wrote:

> Add and use no window scale bit in the features field.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
> Sigend-off-by: Yony Amit <yony@comsleep.com>

The same effect can by just using window limit on route

