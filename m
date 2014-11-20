From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: mlx5: don't duplicate kvfree()
Date: Thu, 20 Nov 2014 10:41:16 +0200
Message-ID: <20141120084116.GA20471@mtldesk30>
References: <20141120081357.GI7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>, roland@purestorage.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36973 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055AbaKTIlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 03:41:20 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so11216109wiv.4
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 00:41:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141120081357.GI7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Eli Cohen <eli@mellanox.com>
