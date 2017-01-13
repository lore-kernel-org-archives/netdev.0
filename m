From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: fdb: add state filter support
Date: Thu, 12 Jan 2017 17:39:25 -0800
Message-ID: <20170112173925.05820b9e@xeon-e3>
References: <1484239659-16565-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        purna@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36607 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdAMBjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:39:33 -0500
Received: by mail-pf0-f172.google.com with SMTP id 189so21992702pfu.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:39:33 -0800 (PST)
In-Reply-To: <1484239659-16565-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 17:47:39 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds a new argument to the bridge fdb show command that allows
> to filter by entry state.
> Also update the man page to include all available show arguments.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

Applied. Extra thanks for remembering to update man page.
