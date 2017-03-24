From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Fri, 24 Mar 2017 15:36:20 -0600
Message-ID: <cb2bb70e-21f0-6386-d5b7-790f380626f5@cumulusnetworks.com>
References: <20170324010227.45375-1-dsa@cumulusnetworks.com>
 <20170324.132939.982617243186545861.davem@davemloft.net>
 <c6ad237b-8a83-32bb-0a1b-3599c8b0d66b@cumulusnetworks.com>
 <20170324.141138.874207018978092750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34701 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751972AbdCXVgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:36:23 -0400
Received: by mail-pf0-f176.google.com with SMTP id p189so1037258pfp.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 14:36:22 -0700 (PDT)
In-Reply-To: <20170324.141138.874207018978092750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/17 3:11 PM, David Miller wrote:
> I did a merge yesterday, so I am not likely to do another for about a week.

hmmm.... some how I missed it. That merge has what I need.
