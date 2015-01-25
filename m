From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] hyperv: netvsc.c: fixup-of-wait_for_completion_timeout-return-type
Date: Sun, 25 Jan 2015 14:37:45 +0300
Message-ID: <54C4D589.3010406@cogentembedded.com>
References: <1422183808-7655-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>,
	"K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:62344 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbAYLhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 06:37:47 -0500
Received: by mail-la0-f42.google.com with SMTP id ms9so3892676lab.1
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 03:37:46 -0800 (PST)
In-Reply-To: <1422183808-7655-1-git-send-email-der.herr@hofr.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/25/2015 2:03 PM, Nicholas Mc Guire wrote:

    You probably want to replace hyphens with spaces in the subject of this 
and other patches.
    And you're not fixing the return type of wait_for_completion_timeout(), 
you're fixing the variables to match this type.

> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>

WBR, Sergei
