From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] net: rocker: Use ether_addr_equal
Date: Thu, 30 Apr 2015 22:05:04 -0700
Message-ID: <CAE4R7bBeMoUoyZoO4WsACDkdBVwi-ZjsuZps+HbpgcOw7zOVmw@mail.gmail.com>
References: <1430374889-7479-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36751 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbEAFFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 01:05:05 -0400
Received: by oift201 with SMTP id t201so64066957oif.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 22:05:05 -0700 (PDT)
In-Reply-To: <1430374889-7479-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:21 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> A small cleanup to make use of the ether_addr_equal helper.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
> ---
> Compile tested only

Passes my tests, thanks Simon.

Acked-by: Scott Feldman <sfeldma@gmail.com>
