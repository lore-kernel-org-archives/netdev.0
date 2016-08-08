From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tc/m_gact: Fix action_a2n() return code check
Date: Mon, 8 Aug 2016 08:55:30 -0700
Message-ID: <20160808085530.04bfb360@xeon-e3>
References: <20160807111621.6D056647E4@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Bloch <markb@mellanox.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36216 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbcHHPzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:55:19 -0400
Received: by mail-pf0-f169.google.com with SMTP id h186so120229856pfg.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 08:55:19 -0700 (PDT)
In-Reply-To: <20160807111621.6D056647E4@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  7 Aug 2016 13:19:01 +0200
Phil Sutter <phil@nwl.cc> wrote:

> The function returns zero on success.
> 
> Reported-by: Mark Bloch <markb@mellanox.com>
> Fixes: 69f5aff63c770b ("tc: use action_a2n() everywhere")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
