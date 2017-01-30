From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] lwtunnel: remove device arg to lwtunnel_build_state
Date: Mon, 30 Jan 2017 13:12:24 -0800
Message-ID: <588FAC38.8090708@cumulusnetworks.com>
References: <1485806857-3651-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34842 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754378AbdA3VM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 16:12:26 -0500
Received: by mail-pf0-f177.google.com with SMTP id f144so93365101pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 13:12:26 -0800 (PST)
In-Reply-To: <1485806857-3651-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17, 12:07 PM, David Ahern wrote:
> Nothing about lwt state requires a device reference, so remove the
> input argument.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - rebased to top of net-next tree
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks David
