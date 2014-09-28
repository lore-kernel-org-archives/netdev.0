From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] add bridge_slave device support
Date: Sun, 28 Sep 2014 16:09:28 -0700
Message-ID: <20140928160928.203fe8d3@urahara>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
	<1409925309-17881-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41041 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbaI1XJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:09:40 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so1517241pad.31
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:09:39 -0700 (PDT)
In-Reply-To: <1409925309-17881-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 15:55:08 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Note this depends on "iproute2: allow to change slave options via
> type_slave"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  ip/Makefile              |   3 +-
>  ip/iplink_bridge_slave.c | 181 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 183 insertions(+), 1 deletion(-)
>  create mode 100644 ip/iplink_bridge_slave.c

Both applied
