From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 5/7] vxlan: simplify RTF_LOCAL handling.
Date: Tue, 15 Nov 2016 15:44:12 +0100
Message-ID: <20161115154412.17bfef4e@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-6-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752586AbcKOOoP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:44:15 -0500
In-Reply-To: <1479098638-4921-6-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Nov 2016 20:43:56 -0800, Pravin B Shelar wrote:
> Avoid code duplicate code for handling RTF_LOCAL routes.
> 
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Jiri Benc <jbenc@redhat.com>
