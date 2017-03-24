From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Fri, 24 Mar 2017 10:05:17 +0000
Message-ID: <7c8e101a-fc99-85bb-b4f8-7d1a411511fd@brocade.com>
References: <20170324010227.45375-1-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:57203 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751995AbdCXKF3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 06:05:29 -0400
In-Reply-To: <20170324010227.45375-1-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/17 01:02, David Ahern wrote:
> Fix copy and paste error setting rt_ttl_propagate.
>
> Fixes: 5b441ac8784c1 ("mpls: allow TTL propagation to IP packets to be configured")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Good catch.

Acked-by: Robert Shearman <rshearma@brocade.com>
