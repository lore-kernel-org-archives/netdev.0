From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc util: Fix possible buffer overflow when
 print class id
Date: Mon, 20 Apr 2015 10:08:51 -0700
Message-ID: <20150420100851.5450adff@urahara>
References: <1429508012-19119-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35742 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbDTRIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 13:08:46 -0400
Received: by pabtp1 with SMTP id tp1so212498042pab.2
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 10:08:46 -0700 (PDT)
In-Reply-To: <1429508012-19119-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2015 08:33:32 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Use correct handle buffer length.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Looks fine, applied.
