From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip neigh: Add support for filtering dumps by master
 device
Date: Mon, 12 Oct 2015 09:40:16 -0700
Message-ID: <20151012094016.43f64463@urahara>
References: <1443804147-40174-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35228 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbJLQkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:40:04 -0400
Received: by pabve7 with SMTP id ve7so100394937pab.2
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:40:04 -0700 (PDT)
In-Reply-To: <1443804147-40174-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Oct 2015 09:42:27 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add support for filtering neighbor dumps by master device. Kernel side
> support provided by commit 21fdd092acc7. Since the feature is not
> available in older kernels the user is given a warning message if the
> kernel does not support the request.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, to net-next branch of iproute2.
