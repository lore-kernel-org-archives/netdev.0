From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] Fix the usage of TC tunnel key
Date: Thu, 22 Dec 2016 11:03:01 -0800
Message-ID: <20161222110301.2d7c830d@xeon-e3>
References: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36373 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966091AbcLVTMH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 14:12:07 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so100643481pgc.3
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 11:12:07 -0800 (PST)
In-Reply-To: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Dec 2016 10:14:39 +0200
Hadar Hen Zion <hadarh@mellanox.com> wrote:

> Add dest UDP port parameter to the usage of tc tunnle key action and
> classifcation.
> 
> 
> Hadar Hen Zion (2):
>   tc/cls_flower: Add to the usage encapsulation dest UDP port
>   tc/m_tunnel_key: Add to the usage encapsulation dest UDP port
> 
>  tc/f_flower.c     | 5 +++--
>  tc/m_tunnel_key.c | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 

Looks good, both applied
