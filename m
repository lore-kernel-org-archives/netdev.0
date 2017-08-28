From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Mon, 28 Aug 2017 15:03:34 -0600
Message-ID: <80c558d4-dea8-3a60-3786-c70e55946ff2@gmail.com>
References: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
 <20170828.140133.2126200702424568912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhumirks@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34309 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1VDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:03:36 -0400
Received: by mail-pg0-f41.google.com with SMTP id y15so4811893pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:03:36 -0700 (PDT)
In-Reply-To: <20170828.140133.2126200702424568912.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/17 3:01 PM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Mon, 28 Aug 2017 13:23:09 -0700
> 
>> This reverts commit aa8db499ea67cff1f5f049033810ffede2fe5ae4.
> ...
>> I think this is the second time such a patch has been reverted.
> 
> Then please add a comment, it will help prevent this from happening
> again.
> 

Was going to do that in both places after the revert. You want it as
part of this one?
