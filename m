From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] e1000e: Add pm_qos header
Date: Wed, 13 May 2015 00:46:32 +0300
Message-ID: <555274B8.5060801@cogentembedded.com>
References: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34117 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932707AbbELVqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 17:46:37 -0400
Received: by laat2 with SMTP id t2so16123724laa.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 14:46:35 -0700 (PDT)
In-Reply-To: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/12/2015 06:36 PM, David Ahern wrote:

> Commit e2c6544829f moved pm_qos_req to e1000_adapter. Add the header file

    Please also specify that commit's summary line in parens.

> that defines the struct.

> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

    Same comment about the 2nd patch.

WBR, Sergei
