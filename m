From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6)
Date: Thu, 7 Jan 2016 17:21:50 +0100
Message-ID: <568E909E.1080409@6wind.com>
References: <1452171793-5829-1-git-send-email-nicolas.dichtel@6wind.com>
 <568E68B2.2040102@iogearbox.net> <568E6EA7.6080304@iogearbox.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Julien Floret <julien.floret@6wind.com>
To: Daniel Borkmann <daniel@iogearbox.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35302 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbcAGQWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 11:22:11 -0500
Received: by mail-wm0-f49.google.com with SMTP id f206so103734552wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 08:22:11 -0800 (PST)
In-Reply-To: <568E6EA7.6080304@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2016 14:56, Daniel Borkmann a =E9crit :
> Btw, for iproute2's net-next branch there're couple of other occasion=
s
> as well. Stephen, how do you prefer to handle this? Should a separate
> patch be done against net-next branch to reduce merge conflicts?
Thank you Daniel for noticing it.
