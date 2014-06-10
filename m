From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/core: Add VF link state control policy
Date: Wed, 11 Jun 2014 00:09:24 +0400
Message-ID: <539765F4.10506@cogentembedded.com>
References: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Doug Ledford <dledford@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:53275 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932562AbaFJUJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 16:09:26 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so4206429lbi.5
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 13:09:24 -0700 (PDT)
In-Reply-To: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/10/2014 11:59 PM, Doug Ledford wrote:

> Commit 1d8faf48c7 added VF link state control to the netlink VF nested

    Please also specify that commit's summary line in parens.

> structure, but failed to add a proper entry for the new structure into
> the VF policy table.  Add the missing entry so the table and the actual
> data copied into the netlink nested struct are in sync.

> Signed-off-by: Doug Ledford <dledford@redhat.com>

WBR, Sergei
