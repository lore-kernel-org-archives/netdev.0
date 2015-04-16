From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH -next] netns: remove duplicated include from net_namespace.c
Date: Thu, 16 Apr 2015 16:12:06 +0200
Message-ID: <552FC336.4000704@6wind.com>
References: <1429190255-24722-1-git-send-email-weiyj_lk@163.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: weiyj_lk@163.com, "David S. Miller" <davem@davemloft.net>,
	xiao jin <jin.xiao@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33172 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbbDPOMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 10:12:09 -0400
Received: by wgin8 with SMTP id n8so82145982wgi.0
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 07:12:08 -0700 (PDT)
In-Reply-To: <1429190255-24722-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/04/2015 15:17, weiyj_lk@163.com a =E9crit :
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Remove duplicated include.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
