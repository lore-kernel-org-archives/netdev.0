From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: replace exit with return
Date: Mon, 11 Jan 2016 08:27:23 -0800
Message-ID: <20160111082723.71f35beb@xeon-e3>
References: <1452384132-32261-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34098 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933099AbcAKQ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 11:27:15 -0500
Received: by mail-pf0-f175.google.com with SMTP id q63so48347253pfb.1
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 08:27:15 -0800 (PST)
In-Reply-To: <1452384132-32261-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Jan 2016 16:02:12 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch replaces exits with returns in iplink
> command. Helps to continue on errors when
> invoked with ip -force -batch.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied thanks
