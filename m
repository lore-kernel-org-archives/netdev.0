From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH iproute2] man ip-netns: Notice about loose device when
 do 'del'
Date: Sun, 15 Mar 2015 12:47:04 +0100
Message-ID: <20150315124704.10365mswq26qzad4@berry.schulz.ip-v6.eu>
References: <1426417044-6754-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([85.158.180.102]:20340 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751772AbbCOLrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 07:47:09 -0400
In-Reply-To: <1426417044-6754-1-git-send-email-vadim4j@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Vadim Kochan schrieb am Sun, 15 Mar 2015 12:57:24 +0200:

> [...]
> +    $ ip netns pids net0 | xargs | kill

Shouldn't this be rather

        $ ip netns pids net0 | xargs kill

?


Regards,

Christoph Schulz
