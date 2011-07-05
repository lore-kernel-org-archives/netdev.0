From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2 1/2] Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem
 tunables
Date: Tue, 05 Jul 2011 10:01:55 +0800
Message-ID: <4E127093.8030504@cn.fujitsu.com>
References: <20110705015723.8B226815DBB1@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61290 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab1GECAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 22:00:49 -0400
In-Reply-To: <20110705015723.8B226815DBB1@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Matveev wrote, at 06/20/2011 04:08 PM:
> sctp does not use second and third ("default" and "max") values
> of sctp_rmem tunable. The format is the same as tcp_rmem
> but the meaning is different so make the documentation explicit to
> avoid confusion.
> 
> sctp_wmem is not used at all.
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Max Matveev <makc@redhat.com>

Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>


-- 
Best Regards
-----
Shan Wei
