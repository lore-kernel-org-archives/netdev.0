From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: mroute: Add table output to show command
Date: Wed, 14 Jun 2017 13:32:44 -0700
Message-ID: <20170614133244.0d1f2aa7@xeon-e3>
References: <1497442092-14252-1-git-send-email-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Donald Sharp <sharpd@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33555 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdFNUcq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:32:46 -0400
Received: by mail-pf0-f182.google.com with SMTP id 83so5647572pfr.0
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 13:32:46 -0700 (PDT)
In-Reply-To: <1497442092-14252-1-git-send-email-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 08:08:12 -0400
Donald Sharp <sharpd@cumulusnetworks.com> wrote:

> When the user specifies `table all` or `table 0` to
> the `ip mroute show` command we dump the entirety of
> the known mroute tables.  Without some sort of
> divisor to tell us what table we are looking at
> the command is useless.
> 
> Add `Table: <vrf name>` to the output of 'ip mroute show table 0'
> 
> Follow the convention established by 'ip route show table 0'
> for when to display
> 
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>

Applied, thanks.
