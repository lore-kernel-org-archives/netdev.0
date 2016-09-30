From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/3] mpls: move mpls_hdr to a common location
Date: Fri, 30 Sep 2016 11:14:59 -0600
Message-ID: <ea41a240-1d44-e106-42f6-5e667d165b72@cumulusnetworks.com>
References: <cover.1475255100.git.jbenc@redhat.com>
 <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32945 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932539AbcI3RPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 13:15:05 -0400
Received: by mail-pa0-f41.google.com with SMTP id cd13so37146871pac.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 10:15:05 -0700 (PDT)
In-Reply-To: <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/30/16 11:08 AM, Jiri Benc wrote:
> This will be also used by openvswitch.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: new in v2
> ---
>  include/net/mpls.h  |  9 +++++++++
>  net/mpls/internal.h | 10 +---------
>  2 files changed, 10 insertions(+), 9 deletions(-)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
