From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_v4_err/request sock refcnt leak?
Date: Mon, 23 Mar 2015 19:03:17 -0700
Message-ID: <1427162597.25985.87.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150323090317.GB8934@haze> <550FEA98.3040009@gmail.com>
	 <1427119917.25985.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5510C2B5.2030609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37851 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbCXCDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:03:19 -0400
Received: by igcqo1 with SMTP id qo1so55387830igc.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 19:03:19 -0700 (PDT)
In-Reply-To: <5510C2B5.2030609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-24 at 09:49 +0800, Fan Du wrote:

> Looks like I've over slept last night.
> Thanks Eric for cooking the patch 8)

Thanks for your help ;)
