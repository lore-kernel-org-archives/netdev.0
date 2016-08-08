From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: vlan json: skip ports with empty vlans
Date: Mon, 8 Aug 2016 08:43:12 -0700
Message-ID: <20160808084312.066f9539@xeon-e3>
References: <1470598623-17215-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35077 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbcHHPoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:44:19 -0400
Received: by mail-pa0-f45.google.com with SMTP id iw10so114927857pac.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 08:44:19 -0700 (PDT)
In-Reply-To: <1470598623-17215-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  7 Aug 2016 12:37:03 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> The non-json output prints 'None' for such vlans.
> And this can garble json output.
> 
> Fixes: d82a49ce85f0 ("bridge: add json support for bridge vlan show")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied
