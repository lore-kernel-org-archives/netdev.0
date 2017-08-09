From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 iproute2] lib: Dump ext-ack string by default
Date: Wed, 9 Aug 2017 09:15:09 -0700
Message-ID: <20170809091509.0b14953c@xeon-e3>
References: <1502293407-4152-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33132 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752544AbdHIQPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:15:18 -0400
Received: by mail-pg0-f52.google.com with SMTP id u5so29957776pgn.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 09:15:18 -0700 (PDT)
In-Reply-To: <1502293407-4152-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  9 Aug 2017 08:43:27 -0700
David Ahern <dsahern@gmail.com> wrote:

> In time, errfn can be implemented for link, route, etc commands to
> give a much more detailed response (e.g., point to the attribute
> that failed). Doing so is much more complicated to process the
> message and convert attribute ids to names.
> 
> In any case the error string returned by the kernel should be dumped
> to the user, so make that happen now.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied
