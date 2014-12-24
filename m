From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip lib: Added shorter timestamp option
Date: Wed, 24 Dec 2014 12:09:08 -0800
Message-ID: <20141224120908.3f4b1d93@urahara>
References: <1419286438-21504-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:61416 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaLXUJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:09:18 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so10411548pdb.32
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:09:18 -0800 (PST)
In-Reply-To: <1419286438-21504-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Dec 2014 00:13:58 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added another timestamp format to look like more logging info:
> 
> [2014-12-22T22:36:50.489 ] 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
>     link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied with some minor changes, the code was initializing more than necessary.
