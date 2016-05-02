From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 1/1] man: tc-ife.8: man page for ife action
Date: Mon, 2 May 2016 15:10:32 -0700
Message-ID: <20160502151032.5701009e@xeon-e3>
References: <1462013884-4971-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, lucasb@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33959 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbcEBWKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 18:10:19 -0400
Received: by mail-pa0-f41.google.com with SMTP id r5so894045pag.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 15:10:19 -0700 (PDT)
In-Reply-To: <1462013884-4971-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Apr 2016 06:58:04 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Lucas Bates <lucasb@mojatatu.com>
> 
> Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Still waiting for a you to respond to my earlier suggestions about tc-ife.

Last version I saw was expecting header in include/linux which is not in
kernel source.

~/kernel/net-next$ ls include/uapi/linux/tc_ife.h
ls: cannot access include/uapi/linux/tc_ife.h: No such file or directory

You need to get that header in right place, and get it exported correctly.
