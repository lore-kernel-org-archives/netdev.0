From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [except_nonlink net-next]r8169:Add exception when missing link
Date: Sat, 11 Jul 2015 22:17:34 +0300
Message-ID: <CAEnQRZBFLhOv8c70KkFchvOoBKX7dEkzeCGGSLEV1RsTs2vmuw@mail.gmail.com>
References: <CAGg4U=EF+_8qLW_K=ZYtLSjC75RSrVywsMVswua0YpM91GYZog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35280 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbGKTRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 15:17:36 -0400
Received: by labgy5 with SMTP id gy5so129445579lab.2
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 12:17:34 -0700 (PDT)
In-Reply-To: <CAGg4U=EF+_8qLW_K=ZYtLSjC75RSrVywsMVswua0YpM91GYZog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 11, 2015 at 9:32 PM, Marian Corcodel
<corcodel.marian@gmail.com> wrote:
> Add exception when missing link because original function "
> rtl8169_check_link_status" must be int instead of void.

Hi Marian,

Please have a look here:

http://kernelnewbies.org/FirstKernelPatch#head-dc6a8aa0be0d0e8ed9dc03726d0b5a1fb0f65e1f

on how you should properly send a patch.

thanks,
Daniel.
