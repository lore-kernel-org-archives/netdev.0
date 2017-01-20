From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2] tc: m_csum: add support for SCTP
 checksum
Date: Fri, 20 Jan 2017 09:32:25 -0800
Message-ID: <20170120093225.760e12d4@xeon-e3>
References: <7e8e15a6e6f11133b4e22166d27d32ad8d5a83e7.1484906832.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gregoire Baron <baronchon@n7mm.org>, Jiri Benc <jbenc@redhat.com>,
        netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34294 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbdATRc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:32:27 -0500
Received: by mail-pf0-f172.google.com with SMTP id e4so23880967pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:32:27 -0800 (PST)
In-Reply-To: <7e8e15a6e6f11133b4e22166d27d32ad8d5a83e7.1484906832.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 11:10:10 +0100
Davide Caratti <dcaratti@redhat.com> wrote:

> 'sctp' parameter can now be used as 'csum' target to enable CRC32c
> computation on SCTP packets.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied to net-next
