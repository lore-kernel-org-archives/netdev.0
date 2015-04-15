From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v3 0/2] iputils ping/ping6: add (non-raw) ICMP socket
 support
Date: Wed, 15 Apr 2015 20:53:25 +0900
Message-ID: <552E5135.1090905@miraclelinux.com>
References: <2533400.J7TS57yqTy@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Lorenzo Colitti <lorenzo@google.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:59006 "HELO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755739AbbDOLxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 07:53:30 -0400
Received: by mail-pd0-f172.google.com with SMTP id qd1so49965088pdb.2
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 04:53:29 -0700 (PDT)
In-Reply-To: <2533400.J7TS57yqTy@msg-id>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Salvatore Mesoraca wrote:
> V2->V3:
>  This patchset is based on the Lorenzo Colitti's one instead of the original by
>  Vasiliy Kulikov. This one also support ping6.
> 
> Salvatore Mesoraca (2):
>   iputils ping/ping6: Add a function to check if a packet is ours
>   iputils ping/ping6: add (non-raw) ICMP socket support
> 
>  doc/ping.sgml |  5 ++--
>  ping.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++++++---------------
>  ping6.c       | 84 ++++++++++++++++++++++++++++++++++++++++----------------------------
>  ping_common.c |  9 ++++++--
>  ping_common.h |  2 ++
>  5 files changed, 121 insertions(+), 57 deletions(-)
> 

Applied.  Thanks a lot.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
