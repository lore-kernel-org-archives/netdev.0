From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/3] ip: add ip sr command to control SR-IPv6
 internal structures
Date: Tue, 10 Jan 2017 10:35:10 -0800
Message-ID: <20170110103510.0abb1be0@xeon-e3>
References: <1484066486-22152-1-git-send-email-david.lebrun@uclouvain.be>
        <1484066486-22152-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34714 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752557AbdAJSfN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:35:13 -0500
Received: by mail-pf0-f181.google.com with SMTP id 127so51009304pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:35:13 -0800 (PST)
In-Reply-To: <1484066486-22152-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jan 2017 17:41:25 +0100
David Lebrun <david.lebrun@uclouvain.be> wrote:

> This patch add commands to support the tunnel source properties
> ("ip sr tunsrc") and the HMAC key -> secret, algorithm binding
> ("ip sr hmac").
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---

Man page?
