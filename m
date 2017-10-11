From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: new option to set neigh suppression on
 a bridge port
Date: Wed, 11 Oct 2017 10:58:15 -0700
Message-ID: <20171011105815.285acbf5@xeon-e3>
References: <1507610533-18724-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:44180 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752525AbdJKR6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:58:18 -0400
Received: by mail-pg0-f51.google.com with SMTP id j3so1402929pga.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:58:18 -0700 (PDT)
In-Reply-To: <1507610533-18724-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Oct 2017 21:42:13 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> neigh suppression can be used to suppress arp and nd flood
> to bridge ports. It maps to the recently added
> kernel support for bridge port flag IFLA_BRPORT_NEIGH_SUPPRESS.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied to net-next branch.
