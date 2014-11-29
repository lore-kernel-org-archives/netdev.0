From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: Add support for enabling UDP checksums
Date: Sat, 29 Nov 2014 11:08:33 -0800
Message-ID: <20141129110833.30095401@urahara>
References: <1415376334-29292-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57351 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbaK2TIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 14:08:44 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so8330027pdj.23
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 11:08:43 -0800 (PST)
In-Reply-To: <1415376334-29292-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Nov 2014 08:05:34 -0800
Tom Herbert <therbert@google.com> wrote:

> Add udpcsum option to enable transmitting UDP checksums when doing
> VXLAN/IPv4. Add udp6zerocsumtx, and udp6zerocsumrx options to enable
> sending zero checksums and receiving zero checksums in VXLAN/IPv6.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.

You probably want to update man page as well.
