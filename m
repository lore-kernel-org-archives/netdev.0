From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 3/5] selinux/nlmsg: add XFRM_MSG_NEWSPDINFO
Date: Thu, 09 Apr 2015 15:11:08 +0200
Message-ID: <55267A6C.3090400@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com> <1428511002-22329-4-git-send-email-nicolas.dichtel@6wind.com> <55267162.7050304@tycho.nsa.gov>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paul Moore <paul@paul-moore.com>
To: Stephen Smalley <sds@tycho.nsa.gov>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55267162.7050304@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/04/2015 14:32, Stephen Smalley a =E9crit :
[snip]
> Seem to be missing a number of the other commands defined in
> include/uapi/linux/xfrm.h as well, e.g. XFRM_MSG_REPORT,
> XFRM_MSG_MIGRATE, XFRM_MSG_NEWSADINFO, XFRM_MSG_GETSADINFO,
> XFRM_MSG_GETSPDINFO, XFRM_MSG_MAPPING.
Right, I will provide a patch.


Thank you,
Nicolas
