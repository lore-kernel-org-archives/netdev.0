From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: bridge: remove unnecessary returns
Date: Sun, 21 Feb 2016 11:59:57 -0800
Message-ID: <20160221115957.6989cede@xeon-e3>
References: <1455825274-8001-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33609 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbcBUT7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 14:59:47 -0500
Received: by mail-pa0-f50.google.com with SMTP id fl4so79051951pad.0
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 11:59:46 -0800 (PST)
In-Reply-To: <1455825274-8001-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2016 20:54:34 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> invarg exits so no need to return, remove this c&p error from my recent
> patches
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied
