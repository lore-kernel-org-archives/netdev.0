From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 0/3 v10] Add support for rmnet driver
Date: Tue, 29 Aug 2017 19:18:05 -0600
Message-ID: <178ce09c87a24b63f6b5057fcd606583@codeaurora.org>
References: <1504054078-10173-1-git-send-email-subashab@codeaurora.org>
 <20170829.180557.1826943085634265902.davem@davemloft.net>
 <20170829.181244.658164638453646342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@aculab.com, marcel@holtmann.org, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53714 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH3BSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:18:06 -0400
In-Reply-To: <20170829.181244.658164638453646342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-08-29 19:12, David Miller wrote:
> Sigh, I had to revert.
> 
> You only allow RMNET to take on the values 'y' and 'n'.
> 
> You must allow for it to be 'm' and modular as well.

Hi David

I'll fix this now.

Sorry about the cover letter. I'll explain it better in subsequent 
submission.
