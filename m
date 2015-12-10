From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip neigh: device is optional for proxy entries
Date: Thu, 10 Dec 2015 09:06:45 -0800
Message-ID: <20151210090645.053fcecc@xeon-e3>
References: <144892182676.2301.1460574558873523132.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Konstantin Khlebnikov <koct9i@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36064 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbLJRGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 12:06:40 -0500
Received: by pacdm15 with SMTP id dm15so50472577pac.3
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 09:06:40 -0800 (PST)
In-Reply-To: <144892182676.2301.1460574558873523132.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Dec 2015 01:17:06 +0300
Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> Though dumping such entries crashes present kernels.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

Applied thanks, but I nobody will use it until after your
kernel patch makes it to stable.
