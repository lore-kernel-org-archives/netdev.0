From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: replace fixed stack allocation with
 dynamic allocation
Date: Mon, 16 Mar 2015 07:40:58 +0100
Message-ID: <20150316064058.GB2032@nanopsycho.orion>
References: <1426485886-61607-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35608 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbbCPGlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:41:01 -0400
Received: by wgdm6 with SMTP id m6so31590710wgd.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:41:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426485886-61607-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 07:04:46AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>In hast to fix some sparse warning, I hard-coded a fix-sized array on the stack
>which is probably too big for kernel standards.  Fix this by converting array
>to dynamic allocation.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
