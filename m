From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Tue, 14 Mar 2017 15:19:03 -0600
Message-ID: <217d998fd9d869f0e5ded0d1add3f550@codeaurora.org>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
 <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
 <20170313085420.GA1796@nanopsycho>
 <868aee1b58aa4365708966956decf6d3@codeaurora.org>
 <20170314065530.GA1863@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57600 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdCNVTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 17:19:05 -0400
In-Reply-To: <20170314065530.GA1863@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I believe that this code should be a part of that driver, not a generic
> code in net/

> 
> ok, so?

Hi Jiri

I will move it to drivers/net and rename it to rmnet.
