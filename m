From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] openvswitch: update kernel doc for struct
 vport
Date: Sun, 10 Jan 2016 11:21:29 +0100
Message-ID: <20160110102129.GC1190@pox.localdomain>
References: <1452380831-11258-4-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
	dev@openvswitch.org
To: J??an Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37677 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbcAJKVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 05:21:31 -0500
Received: by mail-wm0-f52.google.com with SMTP id f206so228780411wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 02:21:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452380831-11258-4-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/16 at 04:07pm, J??an Sacren wrote:
> From: Jean Sacren <sakiwit@gmail.com>
> 
> commit be4ace6e6b1b ("openvswitch: Move dev pointer into vport itself")
> 
> The commit above added @dev and moved @rcu to the bottom of struct
> vport, but the change was not reflected in the kernel doc. So let's
> update the kernel doc as well.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
