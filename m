From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tests: Add output testing
Date: Wed, 24 Jun 2015 23:38:08 -0400
Message-ID: <20150624233808.65b9a08f@uryu.home.lan>
References: <1434576498-6657-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35448 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbFYDiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 23:38:12 -0400
Received: by qkbp125 with SMTP id p125so32390280qkb.2
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 20:38:12 -0700 (PDT)
In-Reply-To: <1434576498-6657-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jun 2015 00:28:18 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added possibility to check command output by grep from the testing
> script.
> 
> Now TMP_OUT & TMP_ERR are passed from Makefile and changed to
> STD_ERR & STD_OUT.
> 
> Also changed some existing tests to make output testing.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>


Looks good applied.
