From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Fri, 24 Feb 2017 08:52:41 -0700
Message-ID: <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
 <20170223163035.0a49f04d@xeon-e3>
 <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
 <20170223.221257.795227595252531962.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34476 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdBXPwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 10:52:44 -0500
Received: by mail-pg0-f48.google.com with SMTP id 1so12913400pgi.1
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 07:52:43 -0800 (PST)
In-Reply-To: <20170223.221257.795227595252531962.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/23/17 8:12 PM, David Miller wrote:
> This really need to be a fundamental facility, so that it transparently
> works for NetworkManager, router daemons, everything.  Not just iproute2
> and "ls".

I'll rebase my patch and send out as RFC.
