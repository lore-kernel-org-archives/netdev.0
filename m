From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Sun, 15 Jan 2017 23:38:30 -0500 (EST)
Message-ID: <20170115.233830.123911280062970298.davem@davemloft.net>
References: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: mayhs11saini@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750856AbdAPEie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 23:38:34 -0500
In-Reply-To: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not ever submit two patches which have the same exact commit
header line, as these two patches do.

When someone looks into the shortlog of GIT history all they will see
is "qed: Replace memset with eth_zero_addr" twice.

This gives the reader no idea what might be different between those
two changes.

Therefore you must give unique a commit header text for each change,
which communicates sufficiently what is different in each change.
