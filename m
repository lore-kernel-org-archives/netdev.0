From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] libs: close file in netns_switch()
Date: Wed, 19 Aug 2015 16:36:06 -0700
Message-ID: <20150819163606.681d7b11@uryu.home.lan>
References: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
	<1439521013-22260-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33215 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbHSXgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 19:36:09 -0400
Received: by padfo6 with SMTP id fo6so7226852pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 16:36:08 -0700 (PDT)
In-Reply-To: <1439521013-22260-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2015 02:56:52 +0000
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Add mising close() calls.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Patch does not apply cleanly to current git code.
